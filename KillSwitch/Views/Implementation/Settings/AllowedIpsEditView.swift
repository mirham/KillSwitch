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
    
    @Injected(\.ipService) private var ipService
    @Injected(\.monitoringService) private var monitoringService
    
    @State private var ipId: UUID?
    @State private var newIp = String()
    @State private var isNewIpValid = false
    @State private var newIpSafetyType: SafetyType = SafetyType.compete
    @State private var isLastIp: Bool = false
    @State private var alertType: AlertType? = nil
    @State private var pendingAlert: AlertType? = nil
    
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
                                Button(action: { handleEditAllowedIpClick(ipAddress: ipAddress) }) {
                                    Text(Constants.edit)
                                }
                                Button(action: { handldeDeleteAllowedIpClick(ipAddress: ipAddress) }) {
                                    Text(Constants.delete)
                                }
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
                            action: handleUpsertAllowedIpClickAsync)
                            .disabled(!isNewIpValid)
                            .bold()
                            .pointerOnHover()
                    }
                }
            }
        }
        .alert(isPresented: Binding(
            get: { alertType != nil },
            set: { _ in
                alertType = pendingAlert
                pendingAlert = nil
            }
        )) {
            if alertType!.alertContent.isDismissableAlert {
                return Alert (
                    title: Text(alertType?.alertContent.title ?? String()),
                    message: Text(alertType?.alertContent.message ?? String()),
                    dismissButton: .default(Text(Constants.ok)) {
                        alertType = pendingAlert
                        pendingAlert = nil
                    }
                )
            }
            else {
                return Alert(
                    title: Text(alertType?.alertContent.title ?? String()),
                    message: Text(alertType?.alertContent.message ?? String()),
                    primaryButton: .destructive(Text(Constants.delete)) {
                        if let ipInfo = alertType?.alertContent.ipInfo,
                           let action = alertType?.alertContent.ipInfoAction {
                            action(ipInfo)
                        }
                    },
                    secondaryButton: .cancel() {
                        alertType = pendingAlert
                        pendingAlert = nil
                    })
            }

        }
    }
    
    // MARK: Private functions
    
    private func handleUpsertAllowedIpClickAsync() async {
        let ipInfoResult = await ipService.getPublicIpInfoAsync(
            apiUrl: appState.userData.ipInfoApiUrl,
            publicIp: newIp,
            keyMapping: appState.userData.ipInfoApiKeyMapping)
        let isNewIpInvalid = appState.userData.pickyMode && ipInfoResult.error != nil
        
        if (isNewIpInvalid) {
            showAlert(.newIpInvalid)
            
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
            ipService.addAllowedPublicIp(publicIp: ipInfo)
        }
        
        ipId = nil
        newIp = String()
        isNewIpValid = false
        newIpSafetyType = SafetyType.compete
    }
    
    private func handleEditAllowedIpClick(ipAddress: IpInfo) {
        ipId = ipAddress.id
        newIp = ipAddress.ipAddress
        newIpSafetyType = ipAddress.safetyType
    }
    
    private func handleLastAllowedIpAlertDeleteClick(ipAddress: IpInfo) {
        monitoringService.stopMonitoring()
        deleteAllowedIpAddress(ipAddress: ipAddress)
    }
    
    private func handldeDeleteAllowedIpClick(ipAddress: IpInfo) {
        isLastIp = appState.monitoring.isEnabled && appState.userData.allowedIps.count == 1
        
        guard !isLastIp else {
             showAlert(.lastAllowedIpDeleting(
                ip: ipAddress,
                ipInfoAction: { ipAddress in handleLastAllowedIpAlertDeleteClick(ipAddress: ipAddress) }))
            
            return
        }
        
        deleteAllowedIpAddress(ipAddress: ipAddress)
    }
    
    private func deleteAllowedIpAddress(ipAddress: IpInfo) {
        appState.userData.allowedIps.removeAll(where: {$0 == ipAddress})
    }
    
    private func showAlert(_ type: AlertType) {
        if alertType == nil {
            alertType = type
        } else {
            pendingAlert = type
        }
    }
    
    // MARK: Inner types
    
    private enum AlertType: Identifiable {
        case newIpInvalid
        case lastAllowedIpDeleting(ip: IpInfo, ipInfoAction: ((_ ipAddress: IpInfo) -> Void))
        
        var id: Int {
            switch self {
                case .newIpInvalid: return 0
                case .lastAllowedIpDeleting: return 1
            }
        }
        
        var alertContent: AlertContent {
            switch self {
                case .newIpInvalid:
                    return AlertContent(
                        title: Constants.dialogHeaderIpIsNotValid,
                        message: Constants.dialogBodyIpIsNotValid)
                case .lastAllowedIpDeleting(let ipInfo, let ipInfoAction):
                    return AlertContent(
                        title: Constants.dialogHeaderLastAllowedIpDeleting,
                        message: String(format: Constants.dialogBodyLastAllowedIpDeleting, ipInfo.ipAddress),
                        ipInfo: ipInfo,
                        ipInfoAction: ipInfoAction)
            }
        }
    }
    
    private struct AlertContent {
        let title: String
        let message: String
        let isDismissableAlert: Bool
        let ipInfo: IpInfo?
        let ipInfoAction: ((_ input: IpInfo) -> Void)?
        
        init(title: String,
             message: String) {
            self.title = title
            self.message = message
            self.isDismissableAlert = true
            self.ipInfo = nil
            self.ipInfoAction = nil
        }
        
        init(title: String,
             message: String,
             ipInfo: IpInfo,
             ipInfoAction: @escaping ((_ input: IpInfo) -> Void)) {
            self.title = title
            self.message = message
            self.isDismissableAlert = false
            self.ipInfo = ipInfo
            self.ipInfoAction = ipInfoAction
        }
    }
}

#Preview {
    AllowedIpsEditView().environmentObject(AppState())
}
