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
    
    private var processCount: Int { appState.system.killingProcesses.count }

    var body: some View {
        StatusCard(
            imageName: Constants.iconApps,
            title: Constants.applications,
            cardBackgroundColor: .orange.opacity(0.08),
            cardBorderColor: .orange.opacity(0.35)
        ) {
            EmptyView()
        } trailingContent: {
            trailingView
        }
        .isHidden(processCount == 0)
        .popover(isPresented: $isHovering, arrowEdge: .trailing) {
            processesPopoverContent
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var trailingView: some View {
        HStack(alignment: .center, spacing: 3) {
            Text("\(processCount)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 28, height: 28)
                .background(Color.orange)
                .clipShape(Circle())
            
            Image(systemName: Constants.iconExpandApps)
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
        }
        .onHover(perform: updateHoverState)
        .pointerOnHover()
        .onTapGesture(perform: handleCloseAllApplicationsButtonClick)
    }
    
    @ViewBuilder
    private var processesPopoverContent: some View {
        VStack {
            Text(Constants.clickToClose)
            
            VStack(alignment: .leading) {
                ForEach(appState.system.killingProcesses, id: \.pid) { processInfo in
                    HStack {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: processInfo.url))
                        Text(processInfo.name)
                    }
                }
            }
        }
        .padding()
        .interactiveDismissDisabled()
    }
    
    // MARK: Private functions
    
    private func updateHoverState(_ hovering: Bool) {
        isHovering = hovering && controlActiveState == .key
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
            .contains(where: { $0 == Constants.windowIdKillProcessesConfirmationDialog })
        
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
