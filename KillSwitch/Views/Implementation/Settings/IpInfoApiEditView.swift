//
//  IpInfoApiEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.06.2025.
//

import SwiftUI
import Factory

struct IpInfoApiEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.ipService) private var ipService
    @Injected(\.ipApiService) private var ipApiService
    @Injected(\.networkService) private var networkService
    
    @State private var apiUrl = String()
    @State private var keyMapping: [String: String] = [:]
    @State private var alertState: AlertState?
    @State private var isSaving = false
    
    var body: some View {
        VStack(alignment: .leading) {
            infoHeader
            Spacer()
                .frame(height: 10)
            settingsForm
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
        }
        .padding(5)
        .onAppear(perform: loadSettings)
        .alert(item: $alertState) { state in
            Alert(
                title: Text(state.title),
                message: Text(state.message),
                dismissButton: .default(Text(Constants.ok))
            )
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var infoHeader: some View {
        HStack {
            Image(systemName: Constants.iconInfoFill)
                .asInfoIcon()
            Text(Constants.hintIpInfoApi)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var settingsForm: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("\(Constants.ipInfoApiUrl):")
                TextField(Constants.hintNewValidApiUrl, text: $apiUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            VStack {
                Text(Constants.mappings)
                    .font(.title3)
                List {
                    ForEach(Array(keyMapping.keys.sorted()), id: \.self) { key in
                        keyMappingRow(for: key)
                    }
                }
            }
        }
        .padding(10)
    }
    
    @ViewBuilder
    private func keyMappingRow(for key: String) -> some View {
        HStack {
            Text(Constants.readableIpInfoApiKeyMapping[key] ?? String())
                .frame(width: 100, alignment: .leading)
                .foregroundColor(.primary)
            TextField(
                Constants.hintJsonKey,
                text: Binding(
                    get: { keyMapping[key] ?? String() },
                    set: { keyMapping[key] = $0 }
                )
            )
            .textFieldStyle(.roundedBorder)
        }
        .padding(.vertical, 2)
    }
    
    @ViewBuilder
    private var saveButton: some View {
        VStack {
            AsyncButton(Constants.save, action: saveSettings)
                .disabled(!hasChanges || isSaving)
                .pointerOnHover()
                .bold()
        }
        .padding(10)
    }
    
    // MARK: Private functions
    
    private func loadSettings() {
        apiUrl = appState.userData.ipInfoApiUrl
        keyMapping = appState.userData.ipInfoApiKeyMapping
    }
    
    private var hasChanges: Bool {
        appState.userData.ipInfoApiUrl != apiUrl ||
        appState.userData.ipInfoApiKeyMapping != keyMapping
    }
    
    private func saveSettings() async {
        isSaving = true
        
        defer { isSaving = false }
        
        do {
            let ipInfo = try await validateAndTestSettings()
            await applySettings(ipInfo)
        } catch let error as IpInfoApiError {
            await MainActor.run {
                alertState = getAlertStateByApiError(for: error)
            }
        } catch {
            await MainActor.run {
                alertState = .validationFailed
            }
        }
    }
    
    private func validateAndTestSettings() async throws -> IpInfoBase {
        guard let publicIp = appState.network.publicIp?.ipAddress
        else { throw IpInfoApiError.noPublicIp }
        
        guard let testUrl = ipApiService.prepareIpInfoApiUrl(
            publicIp: publicIp,
            ipInfoApiUrl: apiUrl
        ) else { throw IpInfoApiError.invalidUrl }
        
        let isReachable = try await networkService.isUrlReachableAsync(url: testUrl)
        
        guard isReachable
        else { throw IpInfoApiError.urlUnreachable }
        
        let testResponse = await ipService.getPublicIpInfoAsync(
            apiUrl: apiUrl,
            publicIp: publicIp,
            keyMapping: keyMapping,
            fetchedFromApi: nil
        )
        
        guard testResponse.success, let ipInfo = testResponse.result
        else { throw IpInfoApiError.invalidApiResponse }
        
        guard ipInfo.hasLocation()
        else { throw IpInfoApiError.missingLocationData }
        
        return ipInfo
    }
    
    private func applySettings(_ ipInfo: IpInfoBase) async {
        await MainActor.run {
            appState.userData.ipInfoApiUrl = apiUrl
            appState.userData.ipInfoApiKeyMapping = keyMapping
        }
        
        await networkService.refreshPublicIpAsync()
    }
    
    private func getAlertStateByApiError(for error: IpInfoApiError) -> AlertState {
        switch error {
            case .noPublicIp, .invalidUrl, .urlUnreachable, .invalidApiResponse:
                return .validationFailed
            case .missingLocationData:
                return .missingLocationData
        }
    }
    
    // MARK: Inner types
    
    private enum AlertState: Identifiable {
        case validationFailed
        case missingLocationData
        
        var id: Self { self }
        
        var title: String {
            switch self {
                case .validationFailed:
                    return Constants.dialogHeaderIpInfoApiIsNotValid
                case .missingLocationData:
                    return Constants.dialogHeaderIpInfoApiMappingIsNotValid
            }
        }
        
        var message: String {
            switch self {
                case .validationFailed:
                    return Constants.dialogBodyIpInfoApiIsNotValid
                case .missingLocationData:
                    return Constants.dialogBodyIpInfoApiMappingIsNotValid
            }
        }
    }
}

#Preview {
    IpApisEditView().environmentObject(AppState())
}
