//
//  AllowedIpsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Network
import Factory

struct AllowedIpsEditView: IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    @Injected(\.ipService) private var ipService
    @Injected(\.monitoringService) private var monitoringService
    
    @State private var editingIpId: UUID?
    @State private var newIpAddress = String()
    @State private var isNewIpValid = false
    @State private var newIpSecurityType: SecurityType = .full
    @State private var alertState: AlertState?
    
    var body: some View {
        VStack(alignment: .leading) {
            infoHeader
            Spacer()
                .frame(height: 10)
            allowedIpsList
        }
        .alert(item: $alertState) { state in
            alert(for: state)
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var infoHeader: some View {
        HStack {
            Image(systemName: Constants.iconInfoFill)
                .asInfoIcon()
            Text(Constants.hintAllowedIps)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var allowedIpsList: some View {
        VStack(alignment: .center) {
            Text(Constants.settingsElementAllowedIpAddresses)
                .font(.title3)
                .multilineTextAlignment(.center)
            NavigationStack {
                List {
                    ForEach(appState.userData.allowedIps, id: \.ipAddress) { ipAddress in
                        ipAddressRow(for: ipAddress)
                            .contextMenu {
                                Button(action: { String.copyToClipboard(input: ipAddress.ipAddress) }) {
                                    Text(Constants.copy)
                                }
                                Button(action: { startEditing(ipAddress) }) {
                                    Text(Constants.edit)
                                }
                                Button(action: { confirmDelete(ipAddress) }) {
                                    Text(Constants.delete)
                                }
                            }
                    }
                }
            }
            .padding(10)
            .safeAreaInset(edge: .bottom) {
                addEditIpForm
            }
        }
    }
    
    @ViewBuilder
    private func ipAddressRow(for ipAddress: IpInfo) -> some View {
        HStack {
            Text(ipAddress.ipAddress)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Image(nsImage: getCountryFlag(countryCode: ipAddress.countryCode))
            
            Text(ipAddress.countryName)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Circle()
                .fill(getSecurityColor(
                    securityType: ipAddress.securityType,
                    colorScheme: colorScheme))
                .frame(width: 10, height: 10)
        }
    }
    
    @ViewBuilder
    private var addEditIpForm: some View {
        VStack {
            HStack {
                Text("\(Constants.ip):")
                    .frame(width: 80, alignment: .leading)
                TextField(Constants.hintNewValidIpAddress, text: $newIpAddress)
                    .onChange(of: newIpAddress) { _, newValue in
                        isNewIpValid = newValue.isValidIp()
                    }
            }
            HStack {
                Text("\(Constants.security):")
                    .frame(width: 80, alignment: .leading)
                
                RadioButton(
                    id: String(SecurityType.full.rawValue),
                    label: SecurityType.full.description,
                    size: 12,
                    color: getSecurityColor(
                        securityType: .full,
                        colorScheme: colorScheme),
                    textSize: 11,
                    isMarked: newIpSecurityType == .full,
                    callback: { _ in newIpSecurityType = .full }
                )
                Spacer()
                    .frame(width: 5)
                RadioButton(
                    id: String(SecurityType.partial.rawValue),
                    label: SecurityType.partial.description,
                    size: 12,
                    color: getSecurityColor(
                        securityType: .partial,
                        colorScheme: colorScheme),
                    textSize: 11,
                    isMarked: newIpSecurityType == .partial,
                    callback: { _ in newIpSecurityType = .partial }
                )
            }
            AsyncButton(
                editingIpId == nil ? Constants.add : Constants.save,
                action: upsertAllowedIpAsync
            )
            .disabled(!isNewIpValid)
            .bold()
            .pointerOnHover()
        }
        .padding(10)
    }
    
    // MARK: Private functions
    
    private func upsertAllowedIpAsync() async {
        let ipInfoResult = await ipService.getPublicIpInfoAsync(
            apiUrl: appState.userData.ipInfoApiUrl,
            publicIp: newIpAddress,
            keyMapping: appState.userData.ipInfoApiKeyMapping,
            fetchedFromApi: nil
        )
        
        let noExtendedIpAddressInfo = appState.userData.useExtendedIpAddressInfo
            && ipInfoResult.error != nil
        
        guard !noExtendedIpAddressInfo else {
            alertState = .newIpInvalid
            
            return
        }
        
        let ipInfo = IpInfo(
            editingIpId ?? UUID(),
            ipAddress: newIpAddress,
            ipAddressInfo: ipInfoResult.result,
            securityType: newIpSecurityType
        )
        
        if let existingIndex = appState.userData.allowedIps
            .firstIndex(where: {
                $0.id == ipInfo.id || $0.ipAddress == ipInfo.ipAddress
            }) {
            appState.userData.allowedIps[existingIndex] = ipInfo
            
            let duplicates = appState.userData.allowedIps
                .filter { $0.ipAddress == newIpAddress }
            
            if duplicates.count > 1, let lastDuplicate = duplicates.last {
                appState.userData.allowedIps
                    .removeAll { $0.id == lastDuplicate.id }
            }
        } else {
            ipService.addAllowedPublicIp(publicIp: ipInfo)
        }
        
        resetForm()
    }
    
    private func startEditing(_ ipAddress: IpInfo) {
        editingIpId = ipAddress.id
        newIpAddress = ipAddress.ipAddress
        newIpSecurityType = ipAddress.securityType
        isNewIpValid = true
    }
    
    private func confirmDelete(_ ipAddress: IpInfo) {
        let isLastActiveIp = appState.monitoring.isEnabled && appState.userData.allowedIps.count == 1
        
        if isLastActiveIp {
            alertState = .lastAllowedIpDeleting(ip: ipAddress)
        } else {
            deleteAllowedIp(ipAddress)
        }
    }
    
    private func deleteAllowedIp(_ ipAddress: IpInfo) {
        appState.userData.allowedIps
            .removeAll { $0 == ipAddress }
    }
    
    private func deleteAllowedIpAndStopMonitoringAsync(_ ipAddress: IpInfo) async {
        await monitoringService.stopMonitoringAsync()
        deleteAllowedIp(ipAddress)
    }
    
    private func resetForm() {
        editingIpId = nil
        newIpAddress = String()
        isNewIpValid = false
        newIpSecurityType = .full
    }
    
    private func alert(for state: AlertState) -> Alert {
        switch state {
            case .newIpInvalid:
                return Alert(
                    title: Text(Constants.dialogHeaderIpIsNotValid),
                    message: Text(Constants.dialogBodyIpIsNotValid),
                    dismissButton: .default(Text(Constants.ok)) {
                        alertState = nil
                    }
                )
            case .lastAllowedIpDeleting(let ip):
                return Alert(
                    title: Text(Constants.dialogHeaderLastAllowedIpDeleting),
                    message: Text(String(format: Constants.dialogBodyLastAllowedIpDeleting, ip.ipAddress)),
                    primaryButton: .destructive(Text(Constants.delete)) {
                        Task { await deleteAllowedIpAndStopMonitoringAsync(ip) }
                        alertState = nil
                    },
                    secondaryButton: .cancel {
                        alertState = nil
                    }
                )
        }
    }
    
    // MARK: Inner types
    
    private enum AlertState: Identifiable {
        case newIpInvalid
        case lastAllowedIpDeleting(ip: IpInfo)
        
        var id: String {
            switch self {
                case .newIpInvalid:
                    return "newIpInvalid"
                case .lastAllowedIpDeleting(let ip):
                    return "lastAllowedIpDeleting_\(ip.id.uuidString)"
            }
        }
    }
}

#Preview {
    AllowedIpsEditView().environmentObject(AppState())
}
