//
//  ProcessesStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Factory

struct ProcessesStatusView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.processService) private var processService
    
    @State private var isHovering = false
    
    var body: some View {
        Section {
            VStack {
                Text(Constants.applications.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Section {
                    processCountView
                        .onTapGesture(perform: handleCloseAllApplicationsButtonClick)
                        .onHover(perform: updateHoverState)
                        .popover(isPresented: $isHovering, arrowEdge: .trailing) {
                            processesPopoverContent
                        }
                }
            }
        }
        .isHidden(appState.system.processesToKill.isEmpty, remove: true)
    }
    
    // MARK: View sections
    
    private var processCountView: some View {
        Text(appState.system.processesToKill.count.description)
            .frame(width: 60, height: 60)
            .background(.yellow)
            .foregroundColor(.black.opacity(0.5))
            .font(.system(size: 18))
            .bold()
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.blue, lineWidth: isHovering ? 2 : 0)
            )
            .pointerOnHover()
    }
    
    @ViewBuilder
    private var processesPopoverContent: some View {
        VStack {
            Text(Constants.clickToClose)
            
            VStack(alignment: .leading) {
                ForEach(appState.system.processesToKill, id: \.pid) {
                    processInfo in
                    HStack {
                        Image(nsImage: NSWorkspace.shared.icon(
                            forFile: processInfo.url))
                        Text(processInfo.name)
                    }
                }
            }
        }
        .padding()
        .interactiveDismissDisabled()
    }
    
    // MARK: Private functions
    
    private func updateHoverState(_ isHovering: Bool) {
        self.isHovering = isHovering && controlActiveState == .key
    }
    
    private func handleCloseAllApplicationsButtonClick() {
        if appState.userData.appsCloseConfirmation {
            showKillProcessesConfirmationDialog()
        } else {
            closeApplications()
        }
    }
    
    private func showKillProcessesConfirmationDialog() {
        let dialogAlreadyShown = appState.views.shownWindows
            .contains(
                where: {
                    $0 == Constants.windowIdKillProcessesConfirmationDialog
                }
            )
        
        guard !dialogAlreadyShown
        else { return }
        
        openWindow(id: Constants.windowIdKillProcessesConfirmationDialog)
    }
    
    private func closeApplications() {
        processService.killActiveProcesses()
        isHovering = false
    }
}

#Preview {
    ProcessesStatusView().environmentObject(AppState())
}
