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
    
    @Query private var allowedIpAddresses: [IpAddressModelNew]
    @Environment(\.modelContext) private var context
    
    @State private var newIp = ""
    @State private var newDescription = ""
    // @State private var newColor = Color(red: 0.11, green: 1.71, blue: 1.07)
    
    let monitoringService = MonitoringService.shared
    
    var body: some View {
        Text("Allowed IP addresses")
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding(.top)
        NavigationStack {
            List {
                ForEach(allowedIpAddresses) { ipAddress in
                    HStack {
                        Text(ipAddress.ip)
                        Spacer()
                        Text(ipAddress.desc)
                        // Spacer()
                        //Text(ipAddress.colorHash)
                    }
                    .contextMenu {
                        Button(action: {context.delete(ipAddress)}){
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
                    
                    let newIpAddress = IpAddressModelNew(ip: newIp, desc: newDescription)
                    context.insert(newIpAddress)
                    
                    monitoringService.allowedIpAddresses.append(newIpAddress.ip)
                    
                    newIp = ""
                    newDescription = ""
                    
                }.bold()
            }
            .padding()
            .background(.bar)
        }
        .onAppear(){
            for allowedIpAddress in allowedIpAddresses {
                monitoringService.allowedIpAddresses.append(allowedIpAddress.ip)
            }
        }
    }
}

#Preview {
    AllowedAddressesView().modelContainer(for: IpAddressModelNew.self)
}
