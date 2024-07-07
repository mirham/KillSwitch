//
//  AllowedAddressesEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Network

struct AllowedAddressesEditView : View {
    @EnvironmentObject var appState: AppState
    
    @State private var newIp = String()
    @State private var isNewIpValid = false
    @State private var newIpSafetyType: SafetyType = SafetyType.compete
    @State private var isNewIpInvalid: Bool = false

    private let ipService = IpService.shared
    
    var body: some View {
        VStack{
            Text(Constants.settingsElementAllowedIpAddresses)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top)
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
                                .fill(getSafetyColor(safetyType: ipAddress.safetyType))
                                .frame(width: 10, height: 10)
                        }
                        .contextMenu {
                            Button(action: { appState.userData.allowedIps.removeAll(where: {$0 == ipAddress})}) {
                                Text(Constants.delete)
                            }
                        }
                    }
                }
            }
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
                                    color: Color.green,
                                    textSize: 11,
                                    isMarked: newIpSafetyType == SafetyType.compete,
                                    callback: { _ in newIpSafetyType = SafetyType.compete }
                                )
                                RadioButton(
                                    id: String(SafetyType.some.rawValue),
                                    label: SafetyType.some.description,
                                    size: 12,
                                    color: Color.yellow,
                                    textSize: 11,
                                    isMarked: newIpSafetyType == SafetyType.some,
                                    callback: { _ in newIpSafetyType = SafetyType.some }
                                )
                            }
                        }
                    }
                    AsyncButton(Constants.add, action: addAllowedIpAddressClickHandlerAsync)
                    .disabled(!isNewIpValid)
                    .alert(isPresented: $isNewIpInvalid) {
                        Alert(title: Text(Constants.dialogHeaderIpAddressIsNotValid),
                              message: Text(Constants.dialogBodyIpAddressIsNotValid),
                              dismissButton: .default(Text(Constants.ok)))
                    }
                    .bold()
                    .pointerOnHover()
                }
                .padding()
            }
        }
    }
    
    // MARK: Private functions
    
    private func addAllowedIpAddressClickHandlerAsync() async {
        let ipInfoResult = await ipService.getIpInfoAsync(ip: newIp)
        
        if (appState.userData.pickyMode && ipInfoResult.error != nil) {
            isNewIpInvalid = true
            
            return
        }
        
        ipService.addAllowedIp(
            ip: newIp,
            ipInfo: ipInfoResult.result,
            safetyType: newIpSafetyType)
        
        newIp = String()
        isNewIpValid = false
        newIpSafetyType = SafetyType.compete
        isNewIpInvalid = false
    }
}

#Preview {
    AllowedAddressesEditView().environmentObject(AppState())
}
