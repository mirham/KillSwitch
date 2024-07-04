//
//  AddressApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI

struct AddressApisEditView : View, Settable {
    @EnvironmentObject var appState: AppState
    
    private let addressesService = AddressesService.shared
    
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
                                    isNewUrlValid = !newUrl.isEmpty && addressesService.validateApiAddress(apiAddressToValidate:newUrl)
                                }
                        }
                    }
                    AsyncButton("Add", action: addAddressApiAsync)
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
    
    private func addAddressApiAsync() async {
        let ipAddress = await addressesService.getCurrentIpAddress(addressApiUrl: newUrl)
        
        guard ipAddress != nil else {
            isNewUrlInvalid = true
            
            return
        }
        
        let newApi = ApiInfo(url: newUrl, active: true)
        
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
    AddressApisEditView().environmentObject(AppState())
}
