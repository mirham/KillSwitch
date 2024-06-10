//
//  AllowedAddressesView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftUI
import SwiftData

struct AllowedAddressesView: View {
    // @Query private var allowedIpAddresses: [IpAddressModelNew]
    // @Environment(\.modelContext) private var context
    
    @EnvironmentObject var monitoringService: MonitoringService
    
    @State private var newIp = ""
    @State private var newDescription = ""
    // @State private var newColor = Color(red: 0.11, green: 1.71, blue: 1.07)
    
    // let monitoringService = MonitoringService.shared
    let ipAddressesService = IpAddressesService.shared
    
    var body: some View {
        Text("Allowed IP addresses")
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding(.top)
        NavigationStack {
            List {
                ForEach(monitoringService.allowedIpAddresses, id: \.ipAddress) { ipAddress in
                    HStack {
                        Text(ipAddress.ipAddress)
                        Spacer()
                        Text(ipAddress.countryName)
                        // Spacer()
                        //Text(ipAddress.colorHash)
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
            VStack(alignment: .center, spacing: 20) {
                Text("New IP address").font(.headline)
                TextField("IP", text: $newIp)
                TextField("Description", text: $newDescription)
                // ColorPicker("Set the background color", selection: $newColor)
                Button("Save") {
                    /*Task {
                        do {
                            var ipInfo = await self.ipAddressesService.callIpAddressInfoApi(ipAddress: newIp)
                        }
                    }*/
                    
                    let newIpAddress = IpAddressInfo(ipVersion: 4, ipAddress: newIp, countryName: newDescription, countryCode: String())
                    
                    monitoringService.allowedIpAddresses.append(newIpAddress)
                    
                    
                    newIp = ""
                    newDescription = ""
                    
                }.bold()
            }
            .padding()
            .background(.bar)
        }
        .onAppear(){
            /*for allowedIpAddress in allowedIpAddresses {
                monitoringService.allowedIpAddresses.append(allowedIpAddress.ip)
            }*/
        }
        .onDisappear(){
            monitoringService.saveAllObjects(allObjects: monitoringService.allowedIpAddresses)
        }
    }
}

#Preview {
    AllowedAddressesView().modelContainer(for: IpAddressModelNew.self)
}
