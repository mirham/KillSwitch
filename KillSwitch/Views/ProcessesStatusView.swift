//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct ProcessesStatusView : View, Settable {
    @Environment(\.openWindow) private var openWindow
    
    @EnvironmentObject var processesService : ProcessesService
    
    @Environment(\.controlActiveState) var controlActiveState
    
    private let appManagementService = AppManagementService.shared
    
    @State private var showOverText = false
    @State private var showConfirmation = false
    
    var body: some View {
        Section() {
            VStack{
                Text("Applications".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Section {
                    Text(processesService.activeProcessesToClose.count.description)
                        .frame(width: 60, height: 60)
                        .background(.yellow)
                        .foregroundColor(.black.opacity(0.5))
                        .font(.system(size: 18))
                        .bold()
                        .clipShape(Circle())
                        .onTapGesture(perform: closeAllpicationsButtonClickHandler)
                        .pointerOnHover()
                }
                .onHover(perform: { hovering in
                    showOverText = hovering && controlActiveState == .key
                })
                .popover(isPresented: ($showOverText), arrowEdge: .trailing, content: {
                    VStack{
                        Text("Click to close")
                        VStack(alignment: .leading) {
                            ForEach(processesService.activeProcessesToClose, id: \.pid) { processInfo in
                                HStack {
                                    Image(nsImage: NSWorkspace.shared.icon(forFile: processInfo.url))
                                    Text(processInfo.name)
                                }
                            }
                        }
                    }
                    .padding()
                    .interactiveDismissDisabled()
                })
                .alert(isPresented: $showConfirmation) {
                    Alert(
                        title: Text(Constants.dialogHeaderCloseApps),
                        message: Text(Constants.dialogBodyCloseApps),
                        primaryButton: Alert.Button.default(Text(Constants.dialogButtonYes), action: {
                            closeApplications()
                            showConfirmation = false
                        }),
                        secondaryButton: .cancel(Text(Constants.dialogButtonNo), action: { showConfirmation = false })
                    )
                }
            }
        }
        .frame(width: 110, height: 90)
        .isHidden(hidden:processesService.activeProcessesToClose.isEmpty, remove: true)
    }
    
    // MARK: Private functions
    
    private func closeAllpicationsButtonClickHandler(){
        let useConfirmation = readSetting(key: Constants.settingsKeyConfirmationApplicationsClose) ?? true
        
        if (useConfirmation) {
            // TODO RUSS: Fix this isuue
            if (appManagementService.isMainViewShowed && !appManagementService.isStatusBarViewShowed) {
                showConfirmation = true
            }
            else {
                showKillProcessesConfirmationDialog()
            }
        }
        else {
            closeApplications()
        }
    }
    
    private func closeApplications(){
        processesService.killActiveProcesses()
        showOverText = false
    }
    
    private func showKillProcessesConfirmationDialog() {
        if(!appManagementService.isKillProcessesConfirmationDialogShowed){
            openWindow(id: Constants.windowIdKillProcessesConfirmationDialog)
            appManagementService.showKillProcessesConfirmationDialog()
        }
    }
}

#Preview {
    ProcessesStatusView()
}
