//
//  ClosingApplicationsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.06.2024.
//

import SwiftUI

struct ClosingApplicationsEditView : View {
    @EnvironmentObject var appState: AppState
    
    @State private var showFileImporter = false
    @State private var isAppToCloseInvalid = false
    @State private var errorMessage = String()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: Constants.iconInfoFill)
                    .asInfoIcon()
                Text(Constants.hintCloseApps)
                    .padding(.top)
                    .padding(.trailing)
            }
            Spacer()
                .frame(height: 10)
            VStack(alignment: .center) {
                Text(Constants.settingsElementClosingApplications)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                NavigationStack {
                    List {
                        ForEach(appState.userData.appsToClose, id: \.id) { appInfo in
                            HStack {
                                Image(nsImage: NSWorkspace.shared.icon(forFile: appInfo.url))
                                Text(appInfo.name)
                            }
                            .contextMenu {
                                Button(action: {appState.userData.appsToClose.removeAll(where: {$0.id == appInfo.id}) }) {
                                    Text(Constants.delete)
                                }
                            }
                        }
                    }
                }
                Button(action: { showFileImporter = true }){
                    Text(Constants.add)
                }
                .padding()
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.application]) { result in
                addAppsToCloseDialogResultHandler(dialogResult: result)
            }
            .fileDialogDefaultDirectory(.applicationDirectory)
            .alert(isPresented: $isAppToCloseInvalid) {
                Alert(title: Text(Constants.dialogHeaderCannotAddAppToClose),
                      message: Text(String(format: Constants.dialogBodyCannotAddAppToClose, errorMessage)),
                      dismissButton: .default(Text(Constants.ok), action: {
                    errorMessage = String()
                    isAppToCloseInvalid = false
                }))
            }
        }
    }
    
    // MARK: Private functions
    
    private func addAppsToCloseDialogResultHandler(dialogResult: Result<URL, any Error>) {
        switch dialogResult {
            case .success(let url):
                let appName = url.deletingPathExtension().lastPathComponent
                let bundle = Bundle(url: url)
                let bundleId = bundle?.bundleIdentifier ?? appName
                let appInfo = AppInfo(
                    url: url.path().removingPercentEncoding ?? String(),
                    name:  appName,
                    bundleId: bundleId)
                
                appState.userData.appsToClose.append(appInfo)
                
                showFileImporter = false
            case .failure(let error):
                errorMessage = error.localizedDescription
                isAppToCloseInvalid = true
                showFileImporter = false
        }
    }
}

#Preview {
    ClosingApplicationsEditView().environmentObject(AppState())
}
