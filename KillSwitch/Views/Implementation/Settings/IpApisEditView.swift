//
//  IpApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI
import Factory

struct IpApisEditView : View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.ipService) private var ipService
    
    @State private var newUrl = String()
    @State private var isNewUrlValid = false
    @State private var isNewUrlInvalid: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfoFill)
                    .asInfoIcon()
                Text(Constants.hintIpApis)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 10)
            VStack(alignment: .center) {
                Text(Constants.settingsElementIpAddressApis)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                NavigationStack {
                    List {
                        ForEach(appState.userData.ipApis, id: \.id) { api in
                            HStack {
                                Text(api.url)
                                Spacer()
                                Circle()
                                    .fill(api.isActive() ? .green : .red)
                                    .frame(width: 10, height: 10)
                                
                            }
                            .help(api.isActive() ? Constants.hintApiIsActive : Constants.hintApiIsInactive)
                            .contextMenu {
                                Button(action: { String.copyToClipboard(input: api.url) } ) {
                                    Text(Constants.copy)
                                }
                                Button(action: { appState.userData.ipApis.removeAll(where: {$0 == api})}) {
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
                                Text("\(Constants.apiUrl):")
                            }
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(Constants.hintNewVaildApiUrl, text: $newUrl)
                                    .onChange(of: newUrl) {
                                        isNewUrlValid = newUrl.isValidUrl()
                                    }
                            }
                        }
                        AsyncButton(Constants.add, action: addIpApiClickHandlerAsync)
                            .disabled(!isNewUrlValid)
                            .alert(isPresented: $isNewUrlInvalid) {
                                Alert(title: Text(Constants.dialogHeaderApiIsNotValid),
                                      message: Text(Constants.dialogBodyApiIsNotValid),
                                      dismissButton: .default(Text(Constants.ok)))
                            }
                            .pointerOnHover()
                            .bold()
                    }
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func addIpApiClickHandlerAsync() async {
        let ipAddressResult = await self.ipService.getPublicIpAsync(
            ipApiUrl: newUrl, withInfo: true)
        
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
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
