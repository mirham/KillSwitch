//
//  AddressApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import Foundation
import SwiftData
import SwiftUI


struct AddressApisEditView: View {
    @EnvironmentObject var addressesService: AddressesService
    
    private let appManagementService = AppManagementService.shared
    
    @State private var newUrl = String()
    
    var body: some View {
        VStack{
            Text("IP Address APIs")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top)
            NavigationStack {
                List {
                    ForEach(addressesService.apis, id: \.id) { api in
                        HStack {
                            Text(api.url)
                            Spacer()
                            switch api.active {
                                case true:
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 10, height: 10)
                                case false:
                                    Circle()
                                        .fill(.yellow)
                                        .frame(width: 10, height: 10)
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                addressesService.apis.removeAll(where: {$0 == api})
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
                            Text("API URL:")
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("New API URL", text: $newUrl)
                        }
                    }
                    Button("Add") {
                        let newApi = ApiInfo(url: newUrl, active: true)
                        
                        addressesService.apis.append(newApi)
                        
                        newUrl = String()
                        
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
                allObjects: addressesService.apis,
                key: appManagementService.apisKey)
        }
    }
}

#Preview {
    AddressApisEditView().environmentObject(AddressesService())
}
