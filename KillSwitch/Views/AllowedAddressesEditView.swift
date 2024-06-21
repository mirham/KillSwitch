//
//  AllowedAddressesEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import FlagKit

struct AllowedAddressesEditView: View {
    @EnvironmentObject var monitoringService: MonitoringService
    
    @State private var newIp = String()
    @State private var isNewIpValid = false
    @State private var newIpAddressSafetyType: AddressSafetyType = AddressSafetyType.compete
    @State private var isNewIpInvalid: Bool = false

    private let addressesService = AddressesService.shared
    private let appManagementService = AppManagementService.shared
    
    var body: some View {
        VStack{
            Text("Allowed IP addresses")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top)
            NavigationStack() {
                List {
                    ForEach(monitoringService.allowedIpAddresses, id: \.ipAddress) { ipAddress in
                        HStack {
                            Text(ipAddress.ipAddress).frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Image(nsImage: Flag(countryCode:ipAddress.countryCode)?.originalImage ?? NSImage())
                            Text(ipAddress.countryName).frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            switch ipAddress.safetyType {
                                case AddressSafetyType.compete:
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 10, height: 10)
                                case AddressSafetyType.some:
                                    Circle()
                                        .fill(.yellow)
                                        .frame(width: 10, height: 10)
                                case .unknown:
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: 5, height: 5)
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                monitoringService.allowedIpAddresses.removeAll(where: {$0 == ipAddress})
                            }){
                                Text("Delete")
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("IP:")
                            Text("Safety:")
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("A new valid IP address", text: $newIp)
                                .onChange(of: newIp) {
                                    isNewIpValid = !newIp.isEmpty && addressesService.validateIpAddress(ipToValidate: newIp)
                                }
                            HStack {
                                RadioButton(
                                    id: String(AddressSafetyType.compete.rawValue),
                                    label: "Complete",
                                    size: 12,
                                    color: Color.green,
                                    textSize: 11,
                                    isMarked: newIpAddressSafetyType == AddressSafetyType.compete ? true : false,
                                    callback: { _ in newIpAddressSafetyType = AddressSafetyType.compete }
                                )
                                RadioButton(
                                    id: String(AddressSafetyType.some.rawValue),
                                    label: "Some",
                                    size: 12,
                                    color: Color.yellow,
                                    textSize: 11,
                                    isMarked: newIpAddressSafetyType == AddressSafetyType.some ? true : false,
                                    callback: { _ in newIpAddressSafetyType = AddressSafetyType.some }
                                )
                            }
                        }
                    }
                    AsyncButton("Add", action: addAllowedIpAddressAsync)
                    .disabled(!isNewIpValid)
                    .alert(isPresented: $isNewIpInvalid) {
                        Alert(title: Text(Constants.dialogHeaderIpAddressIsNotValid),
                              message: Text(Constants.dialogBodyIpAddressIsNotValid),
                              dismissButton: .default(Text(Constants.dialogButtonOk)))
                    }
                    .bold()
                    .onHover(perform: { hovering in
                        if hovering {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    })
                }
                .padding()
            }
        }
        .onDisappear(){
            writeSettings()
        }
    }
    
    // MARK: Private functions
    
    private func addAllowedIpAddressAsync() async {
        let ipAddressInfo = await addressesService.getIpAddressInfo(ipAddress: newIp)
        
        guard ipAddressInfo != nil else {
            isNewIpInvalid = true
            
            return
        }
        
        monitoringService.addAllowedIpAddress(
            ipAddress: newIp,
            ipAddressInfo: ipAddressInfo,
            safetyType: newIpAddressSafetyType)
        
        newIp = String()
        isNewIpValid = false
        newIpAddressSafetyType = AddressSafetyType.compete
        isNewIpInvalid = false
    }
    
    private func writeSettings() {
        appManagementService.writeSettingsArray(
            allObjects: monitoringService.allowedIpAddresses,
            key: Constants.settingsKeyAddresses)
    }
}

#Preview {
    AllowedAddressesEditView().environmentObject(MonitoringService())
}
