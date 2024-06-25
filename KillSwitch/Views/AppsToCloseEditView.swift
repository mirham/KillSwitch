//
//  ApplicationsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 25.06.2024.
//

import Foundation
import SwiftUI

struct AppsToCloseEditView: View {
    @EnvironmentObject var computerManagementService: ComputerManagementService
    
    private let appManagementService = AppManagementService.shared
    private let loggingService = LoggingService.shared
    
    @State private var showFileImporter = false
    
    var body: some View {
        VStack{
            Text("Applications to close")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top)
            NavigationStack {
                List {
                    ForEach(computerManagementService.applicationsToClose, id: \.id) { appInfo in
                        HStack {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: appInfo.url))
                            Text(appInfo.name)
                        }
                        .contextMenu {
                            Button(action: {
                                computerManagementService.applicationsToClose.removeAll(where: {$0.id == appInfo.id})
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
    }
    
    // MARK: Private functions
    
    private func addAppToClose(dialogResult: Result<URL, any Error>) {
        switch dialogResult {
            case .success(let url):
                let appName = url.deletingPathExtension().lastPathComponent
                let bundle = Bundle(url: url)
                let executableName = URL(string: bundle?.executablePath ?? String())?.lastPathComponent  ?? appName
                let appInfo = AppInfo(url: url.path().removingPercentEncoding ?? String(), name:  appName, executableName: executableName)
                
                computerManagementService.applicationsToClose.append(appInfo)
                
                writeSettings()
                
                showFileImporter = false
            case .failure(let error):
                loggingService.log(message: String(format: Constants.logCannotAddAppToClose, error.localizedDescription), type: .error)
                showFileImporter = false
        }
    }
    
    private func writeSettings() {
        appManagementService.writeSettingsArray(
            allObjects: computerManagementService.applicationsToClose,
            key: Constants.settingsKeyAppsToClose)
    }
}

#Preview {
    AppsToCloseEditView()
}
