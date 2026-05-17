//
//  ClosingAppsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.06.2024.
//

import SwiftUI

struct ClosingAppsEditView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var isFileImporterPresented = false
    @State private var alertState: AlertState?
    
    var body: some View {
        VStack(alignment: .leading) {
            infoHeader
            Spacer()
                .frame(height: 10)
            appsList
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.application]
        ) { result in
            handleFileImporterResult(result)
            isFileImporterPresented = false
        }
        .fileDialogDefaultDirectory(.applicationDirectory)
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
            Text(Constants.hintCloseApps)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var appsList: some View {
        VStack(alignment: .center) {
            Text(Constants.settingsElementClosingApplications)
                .font(.title3)
                .multilineTextAlignment(.center)
            NavigationStack {
                List {
                    ForEach(appState.userData.closingApps, id: \.id) { appInfo in
                        appRow(for: appInfo)
                            .contextMenu {
                                Button(
                                    role: .destructive,
                                    action: { deleteApp(appInfo) }) {
                                    Text(Constants.delete)
                                }
                            }
                    }
                }
                .padding(10)
            }
            .safeAreaInset(edge: .bottom) {
                addButton
            }
        }
    }
    
    @ViewBuilder
    private func appRow(for appInfo: AppInfo) -> some View {
        HStack {
            Image(nsImage: NSWorkspace.shared.icon(forFile: appInfo.url))
            Text(appInfo.name)
        }
    }
    
    @ViewBuilder
    private var addButton: some View {
        Button(action: { isFileImporterPresented = true }) {
            Text(Constants.add)
        }
        .padding(10)
    }
    
    // MARK: Private functions
    
    private func handleFileImporterResult(_ result: Result<URL, Error>) {
        switch result {
            case .success(let url):
                addApp(at: url)
            case .failure(let error):
                showError(error.localizedDescription)
        }
    }
    
    private func addApp(at url: URL) {
        let appName = url.deletingPathExtension().lastPathComponent
        let bundle = Bundle(url: url)
        let bundleId = bundle?.bundleIdentifier ?? appName
        let appInfo = AppInfo(
            url: url.path().removingPercentEncoding ?? String(),
            name: appName,
            bundleId: bundleId
        )
        
        appState.userData.closingApps.append(appInfo)
    }
    
    private func deleteApp(_ appInfo: AppInfo) {
        appState.userData.closingApps
            .removeAll { $0.id == appInfo.id }
    }
    
    private func showError(_ message: String) {
        alertState = .addAppFailed(message: message)
    }
    
    // MARK: Inner types
    
    private enum AlertState: Identifiable {
        case addAppFailed(message: String)
        
        var id: String {
            switch self {
                case .addAppFailed:
                    return "addAppFailed"
            }
        }
        
        var title: String {
            Constants.dialogHeaderCannotAddAppToClose
        }
        
        var message: String {
            switch self {
                case .addAppFailed(let message):
                    return String(format: Constants.dialogBodyCannotAddAppToClose, message)
            }
        }
    }
}

#Preview {
    ClosingAppsEditView().environmentObject(AppState())
}
