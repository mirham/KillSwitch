//
//  IpApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI
import Factory

struct IpApisEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.ipService) private var ipService
    
    @State private var newApiUrl = String()
    @State private var isNewUrlValid = false
    @State private var alertState: AlertState?
    
    var body: some View {
        VStack(alignment: .leading) {
            infoHeader
            Spacer()
                .frame(height: 10)
            ipApisList
        }
        .alert(item: $alertState) { state in
            Alert(
                title: Text(state.title),
                message: Text(state.message),
                dismissButton: .default(Text(Constants.ok)) {
                    alertState = nil
                }
            )
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var infoHeader: some View {
        HStack {
            Image(systemName: Constants.iconInfoFill)
                .asInfoIcon()
            Text(Constants.hintIpApis)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var ipApisList: some View {
        VStack(alignment: .center) {
            Text(Constants.settingsElementIpAddressApis)
                .font(.title3)
                .multilineTextAlignment(.center)
            NavigationStack {
                List {
                    ForEach(appState.userData.ipApis, id: \.id) { api in
                        ipApiRow(for: api)
                            .contextMenu {
                                Button(action: { String.copyToClipboard(input: api.url) }) {
                                    Text(Constants.copy)
                                }
                                Button(action: { confirmDelete(api.url) }) {
                                    Text(Constants.delete)
                                }
                            }
                    }
                }
                .padding(10)
            }
            .safeAreaInset(edge: .bottom) {
                addApiForm
            }
        }
    }
    
    @ViewBuilder
    private func ipApiRow(for api: IpApiInfo) -> some View {
        HStack {
            Text(api.url)
            Spacer()
            Circle()
                .fill(api.isActive() ? .green : .red)
                .frame(width: 10, height: 10)
        }
        .help(api.isActive()
              ? Constants.hintApiIsActive
              : Constants.hintApiIsInactive)
    }
    
    @ViewBuilder
    private var addApiForm: some View {
        VStack {
            HStack {
                Text("\(Constants.apiUrl):")
                TextField(Constants.hintNewValidApiUrl, text: $newApiUrl)
                    .onChange(of: newApiUrl) { _, newValue in
                        isNewUrlValid = newValue.isValidUrl()
                    }
            }
            AsyncButton(Constants.add, action: addNewApiAsync)
                .disabled(!isNewUrlValid)
                .pointerOnHover()
                .bold()
        }
        .padding(10)
    }
    
    // MARK: Private functions
    
    private func addNewApiAsync() async {
        let ipAddressResult = await ipService.getPublicIpAsync(
            ipApiUrl: newApiUrl,
            withInfo: true
        )
        
        guard ipAddressResult.success else {
            alertState = .apiInvalid
            return
        }
        
        let isDuplicate = appState.userData.ipApis
            .contains { $0.url == newApiUrl }
        
        guard !isDuplicate
        else { return }
        
        let newApi = IpApiInfo(url: newApiUrl, active: true)
        appState.userData.ipApis.append(newApi)
        appState.userData.ipApisRemoved.removeAll { $0.url == newApiUrl }
        
        resetForm()
    }
    
    private func confirmDelete(_ apiUrl: String) {
        let isLastApi = appState.userData.ipApis.count <= Constants.minIpApiCount
        
        guard !isLastApi else {
            alertState = .lastApiCannotBeRemoved
            
            return
        }
        
        deleteApi(at: apiUrl)
    }
    
    private func deleteApi(at apiUrl: String) {
        appState.userData.ipApis.removeAll { $0.url == apiUrl }
        appState.userData.ipApisRemoved.append(IpApiInfo(url: apiUrl))
    }
    
    private func resetForm() {
        newApiUrl = String()
        isNewUrlValid = false
    }
    
    // MARK: Inner types
    
    private enum AlertState: Identifiable {
        case apiInvalid
        case lastApiCannotBeRemoved
        
        var id: Self { self }
        
        var title: String {
            switch self {
                case .apiInvalid:
                    return Constants.dialogHeaderApiIsNotValid
                case .lastApiCannotBeRemoved:
                    return Constants.dialogHeaderLastIpApiCannotBeRemoved
            }
        }
        
        var message: String {
            switch self {
                case .apiInvalid:
                    return Constants.dialogBodyApiIsNotValid
                case .lastApiCannotBeRemoved:
                    return Constants.dialogBodyLastIpApiCannotBeRemoved
            }
        }
    }
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
