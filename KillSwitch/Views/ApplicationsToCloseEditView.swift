//
//  ApplicationsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.06.2024.
//

import Foundation
import SwiftUI

struct ApplicationsToCloseEditView : View, Settable {
    @EnvironmentObject var processesService: ProcessesService
    
    @State private var showFileImporter = false
    @State private var isAppToCloseInvalid = false
    @State private var errorMessage = String()
    
    var body: some View {
        VStack{
            Text("Applications to close")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top)
            NavigationStack {
                List {
                    ForEach(processesService.applicationsToClose, id: \.id) { appInfo in
                        HStack {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: appInfo.url))
                            Text(appInfo.name)
                        }
                        .contextMenu {
                            Button(action: {
                                processesService.applicationsToClose.removeAll(where: {$0.id == appInfo.id})
                                writeSettings()
                            }){
                                Text("Delete")
                            }
                        }
                    }
                }
            }
            Button(action: {
                showFileImporter = true
            }){
                Text("Add")
            }
            .padding()
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.application]) { result in
            addAppToClose(dialogResult: result)
        }
        .fileDialogDefaultDirectory(.applicationDirectory)
        .alert(isPresented: $isAppToCloseInvalid) {
            Alert(title: Text(Constants.dialogHeaderCannotAddAppToClose),
                  message: Text(String(format: Constants.dialogBodyCannotAddAppToClose, errorMessage)),
                  dismissButton: .default(Text(Constants.dialogButtonOk), action: {
                errorMessage = String()
                isAppToCloseInvalid = false
            }))
        }
    }
    
    // MARK: Private functions
    
    private func addAppToClose(dialogResult: Result<URL, any Error>) {
        switch dialogResult {
            case .success(let url):
                let appName = url.deletingPathExtension().lastPathComponent
                let bundle = Bundle(url: url)
                let bundleId = bundle?.bundleIdentifier ?? appName
                let appInfo = AppInfo(url: url.path().removingPercentEncoding ?? String(), name:  appName, bundleId: bundleId)
                
                processesService.applicationsToClose.append(appInfo)
                
                writeSettings()
                
                showFileImporter = false
            case .failure(let error):
                errorMessage = error.localizedDescription
                isAppToCloseInvalid = true
                showFileImporter = false
                
        }
    }
    
    private func writeSettings() {
        writeSettingsArray(
            allObjects: processesService.applicationsToClose,
            key: Constants.settingsKeyAppsToClose)
    }
}

#Preview {
    ApplicationsToCloseEditView()
}
