//
//  AddressApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI

struct IpApisEditView : View, Settable {
    @EnvironmentObject var appState: AppState
    
    private let addressesService = IpService.shared
    
    @State private var newUrl = String()
    @State private var isNewUrlValid = false
    @State private var isNewUrlInvalid: Bool = false
    
    var body: some View {
        VStack{
            Text("IP Address APIs")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top)
            NavigationStack {
                List {
                    ForEach(appState.userData.ipApis, id: \.id) { api in
                        HStack {
                            Text(api.url)
                            Spacer()
                            Circle()
                                .fill((api.active == nil || api.active!) ? .green : .red)
                                .fill((api.active == nil || api.active!) ? .green : .red)
                                .frame(width: 10, height: 10)
                                .help(Constants.hintApiIsActive)
                        }
                        .contextMenu {
                            Button(action: {
                                appState.userData.ipApis.removeAll(where: {$0 == api})
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
                                .onChange(of: newUrl) {
                                    isNewUrlValid = newUrl.isValidUrl()
                                }
                        }
                    }
                    AsyncButton("Add", action: addIpApiAsync)
                    .disabled(!isNewUrlValid)
                    .alert(isPresented: $isNewUrlInvalid) {
                        Alert(title: Text(Constants.dialogHeaderApiIsNotValid),
                              message: Text(Constants.dialogBodyApiIsNotValid),
                              dismissButton: .default(Text(Constants.dialogButtonOk)))
                    }
                    .pointerOnHover()
                    .bold()
                }
                .padding()
            }
        }
        .onDisappear() {
            writeSettings()
        }
    }
    
    // MARK: Private functions
    
    private func addIpApiAsync() async {
        let ipAddressResult = await addressesService.getCurrentIpAsync(ipApiUrl: newUrl)
        
        guard ipAddressResult.success else {
            isNewUrlInvalid = true
            
            return
        }
        
        let newApi = IpApiInfo(url: newUrl, active: true)
        
        appState.userData.ipApis.append(newApi)
        
        newUrl = String()
        isNewUrlValid = false
        isNewUrlInvalid = false
    }
    
    private func writeSettings() {
        writeSettingsArray(
            allObjects: appState.userData.ipApis,
            key: Constants.settingsKeyApis)
    }
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
