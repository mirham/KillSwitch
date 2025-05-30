//
//  AllowedIpsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Network
import Factory

struct AllowedIpsEditView : IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var ipId: UUID?
    @State private var newIp = String()
    @State private var isNewIpValid = false
    @State private var newIpSafetyType: SafetyType = SafetyType.compete
    @State private var isNewIpInvalid: Bool = false
    @State private var isLastIp: Bool = false
    
    @Injected(\.ipService) private var ipService
    @Injected(\.monitoringService) private var monitoringService
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfoFill)
                    .asInfoIcon()
                Text(Constants.hintAllowedIps)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 10)
            VStack(alignment: .center) {
                Text(Constants.settingsElementAllowedIpAddresses)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                NavigationStack() {
                    List {
                        ForEach(appState.userData.allowedIps, id: \.ipAddress) { ipAddress in
                            HStack {
                                Text(ipAddress.ipAddress)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Image(nsImage: getCountryFlag(countryCode: ipAddress.countryCode))
                                Text(ipAddress.countryName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Circle()
                                    .fill(getSafetyColor(safetyType: ipAddress.safetyType, colorScheme: colorScheme))
                                    .frame(width: 10, height: 10)
                            }
                            .contextMenu {
                                Button(action: { String.copyToClipboard(input: ipAddress.ipAddress) } ) {
                                    Text(Constants.copy)
                                }
                                Button(action: { editAllowedIpClickHandler(ipAddress: ipAddress) }) {
                                    Text(Constants.edit)
                                }
                                Button(action: { deleteAllowedIpClickHandler(ipAddress: ipAddress) }) {
                                    Text(Constants.delete)
                                }
                            }
                            .alert(isPresented: $isLastIp) {
                                Alert(title: Text(Constants.dialogHeaderLastAllowedIpAddressDeleting),
                                      message: Text(String(format: Constants.dialogBodyLastAllowedIpAddressDeleting, ipAddress.ipAddress)),
                                      primaryButton: .destructive(Text(Constants.delete)) {
                                    lastAllowedIpAlertDeleteClickHandler(ipAddress: ipAddress)
                                },
                                      secondaryButton: .cancel())
                            }
                        }
                    }
                }
                .padding(.bottom, 10)
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(Constants.ip):")
                                Text("\(Constants.safety):")
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(Constants.hintNewVaildIpAddress, text: $newIp)
                                    .onChange(of: newIp) {
                                        isNewIpValid = newIp.isValidIp()
                                    }
                                HStack {
                                    RadioButton(
                                        id: String(SafetyType.compete.rawValue),
                                        label: SafetyType.compete.description,
                                        size: 12,
                                        color: getSafetyColor(safetyType: .compete, colorScheme: colorScheme),
                                        textSize: 11,
                                        isMarked: newIpSafetyType == SafetyType.compete,
                                        callback: { _ in newIpSafetyType = SafetyType.compete }
                                    )
                                    RadioButton(
                                        id: String(SafetyType.some.rawValue),
                                        label: SafetyType.some.description,
                                        size: 12,
                                        color: getSafetyColor(safetyType: .some, colorScheme: colorScheme),
                                        textSize: 11,
                                        isMarked: newIpSafetyType == SafetyType.some,
                                        callback: { _ in newIpSafetyType = SafetyType.some }
                                    )
                                }
                            }
                        }
                        AsyncButton(
                            ipId == nil ? Constants.add : Constants.save,
                            action: upsertAllowedIpClickHandlerAsync)
                            .disabled(!isNewIpValid)
                            .alert(isPresented: $isNewIpInvalid) {
                                Alert(title: Text(Constants.dialogHeaderIpAddressIsNotValid),
                                      message: Text(Constants.dialogBodyIpAddressIsNotValid),
                                      dismissButton: .default(Text(Constants.ok)))
                            }
                            .bold()
                            .pointerOnHover()
                    }
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func upsertAllowedIpClickHandlerAsync() async {
        let ipInfoResult = await ipService.getPublicIpInfoAsync(ip: newIp)
        
        if (appState.userData.pickyMode && ipInfoResult.error != nil) {
            isNewIpInvalid = true
            
            return
        }
        
        let ipInfo = IpInfo(
            ipId ?? UUID(),
            ipAddress: newIp,
            ipAddressInfo: ipInfoResult.result,
            safetyType: newIpSafetyType)
        
        if let currentIpIndex = appState.userData.allowedIps.firstIndex(
            where: {$0.id == ipInfo.id || $0.ipAddress == ipInfo.ipAddress}) {
            appState.userData.allowedIps[currentIpIndex] = ipInfo
            
            let matches = appState.userData.allowedIps.filter({$0.ipAddress == newIp})
            
            if(matches.count > 1) {
                appState.userData.allowedIps.removeAll(where: {$0.id == matches.last!.id})
            }
        }
        else {
            ipService.addAllowedPublicIp(ip: ipInfo)
        }
        
        ipId = nil
        newIp = String()
        isNewIpValid = false
        newIpSafetyType = SafetyType.compete
        isNewIpInvalid = false
    }
    
    private func editAllowedIpClickHandler(ipAddress: IpInfo) {
        ipId = ipAddress.id
        newIp = ipAddress.ipAddress
        newIpSafetyType = ipAddress.safetyType
    }
    
    private func lastAllowedIpAlertDeleteClickHandler(ipAddress: IpInfo) {
        monitoringService.stopMonitoring()
        deleteAllowedIpAddress(ipAddress: ipAddress)
    }
    
    private func deleteAllowedIpClickHandler(ipAddress: IpInfo) {
        isLastIp = appState.monitoring.isEnabled && appState.userData.allowedIps.count == 1
        
        if (!isLastIp) {
            deleteAllowedIpAddress(ipAddress: ipAddress)
        }
    }
    
    private func deleteAllowedIpAddress(ipAddress: IpInfo) {
        appState.userData.allowedIps.removeAll(where: {$0 == ipAddress})
    }
}

#Preview {
    AllowedIpsEditView().environmentObject(AppState())
}
