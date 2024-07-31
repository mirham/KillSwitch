//
//  ProcessesStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct ProcessesStatusView : View {
    @EnvironmentObject var appState: AppState

    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    private let processesService = ProcessesService.shared
    
    @State private var showOverText = false
    
    var body: some View {
        Section() {
            VStack{
                Text(Constants.applications.uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Section {
                    Text(appState.system.processesToKill.count.description)
                        .frame(width: 60, height: 60)
                        .background(.yellow)
                        .foregroundColor(.black.opacity(0.5))
                        .font(.system(size: 18))
                        .bold()
                        .clipShape(Circle())
                        .overlay(content: { Circle().stroke(.blue, lineWidth: showOverText ? 2 : 0) })
                        .onTapGesture(perform: closeAllpicationsButtonClickHandler)
                        .pointerOnHover()
                }
                .onHover(perform: { hovering in
                    showOverText = hovering && controlActiveState == .key
                })
                .popover(isPresented: ($showOverText), arrowEdge: .trailing, content: {
                    VStack{
                        Text(Constants.clickToClose)
                        VStack(alignment: .leading) {
                            ForEach(appState.system.processesToKill, id: \.pid) { processInfo in
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
            }
        }
        .frame(width: 110, height: 90)
        .isHidden(hidden:appState.system.processesToKill.isEmpty, remove: true)
    }
    
    // MARK: Private functions
    
    private func closeAllpicationsButtonClickHandler(){
        if (appState.userData.appsCloseConfirmation) {
            showKillProcessesConfirmationDialog()
        }
        else {
            closeApplications()
        }
    }
    
    private func showKillProcessesConfirmationDialog() {
        if(!appState.views.isKillProcessesConfirmationDialogShown){
            openWindow(id: Constants.windowIdKillProcessesConfirmationDialog)
            appState.views.isKillProcessesConfirmationDialogShown = true
        }
    }
    
    private func closeApplications(){
        processesService.killActiveProcesses()
        showOverText = false
    }
}

#Preview {
    ProcessesStatusView().environmentObject(AppState())
}
