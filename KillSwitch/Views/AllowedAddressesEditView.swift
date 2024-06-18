//
//  AllowedAddressesEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftUI
import SwiftData

struct AllowedAddressesEditView: View {
    @EnvironmentObject var monitoringService: MonitoringService
    
    @State private var newIp = String()
    @State private var newDescription = String()
    @State private var newIpAddressSafetyType: AddressSafetyType = AddressSafetyType.compete

    private let ipAddressesService = AddressesService.shared
    private let appManagementService = AppManagementService.shared
    
    var body: some View {
        VStack{
            Text("Allowed IP addresses")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top)
                .help("Just do something")
            NavigationStack {
                List {
                    ForEach(monitoringService.allowedIpAddresses, id: \.ipAddress) { ipAddress in
                        HStack {
                            Text(ipAddress.ipAddress)
                            Spacer()
                            Text(ipAddress.countryName)
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
                            Text("Description:")
                            Text("Safety:")
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("A new IP address", text: $newIp)
                            TextField("Description", text: $newDescription)
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
                    Button("Add") {
                        let newIpAddress = AddressInfo(ipVersion: 4, ipAddress: newIp, countryName: newDescription, countryCode: String(), safetyType: newIpAddressSafetyType)
                        
                        monitoringService.allowedIpAddresses.append(newIpAddress)
                        
                        newIp = String()
                        newDescription = String()
                        newIpAddressSafetyType = AddressSafetyType.compete
                        
                    }.bold()
                }
                .padding()
            }
        }
        .onAppear(){
            /*for allowedIpAddress in allowedIpAddresses {
             monitoringService.allowedIpAddresses.append(allowedIpAddress.ip)
             }*/
        }
        .onDisappear(){
            appManagementService.writeSettingsArray(
                allObjects: monitoringService.allowedIpAddresses,
                key: appManagementService.addressessSettingsKey)
        }
    }
}

#Preview {
    AllowedAddressesEditView().environmentObject(MonitoringService())
}
