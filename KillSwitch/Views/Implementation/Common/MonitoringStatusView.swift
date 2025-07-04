//
//  MonitoringStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Factory

struct MonitoringStatusView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.monitoringService) private var monitoringService
    
    @State private var showOverText = false
    
    var body: some View {
        Section() {
            VStack{
                Text(Constants.monitoring.uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                renderMonitoringStatusControl()
            }
        }
        .frame(width: 110, height: 90)
    }
    
    // MARK: Private functions
    
    private func renderMonitoringStatusControl() -> some View {
        let data = getMonitoringStatusControlData()
        
        let result = Text(data.text.uppercased())
            .frame(width: 60, height: 60)
            .background(data.color)
            .foregroundColor(.black.opacity(0.5))
            .font(.system(size: 18))
            .bold()
            .clipShape(Circle())
            .overlay(content: { Circle().stroke(.blue, lineWidth: showOverText ? 2 : 0) })
            .onTapGesture(perform: toggleMotinoring)
            .pointerOnHover()
            .onHover(perform: { hovering in
                showOverText = hovering && controlActiveState == .key
            })
            .popover(isPresented: $showOverText, arrowEdge: .trailing, content: {
                Text(data.hintText)
                    .padding()
                    .interactiveDismissDisabled()
            })
        
        return result
    }
    
    private func getMonitoringStatusControlData() -> MonitoringStatusControlData {
        switch appState.monitoring.isEnabled {
            case true:
                return MonitoringStatusControlData(
                    text:Constants.on,
                    color: .green,
                    hintText: Constants.hintClickToDisableMonitoring)
            case false:
                return MonitoringStatusControlData(
                    text:Constants.off,
                    color: .red,
                    hintText: Constants.hintClickToEnableMonitoring)
        }
    }
    
    
    private func toggleMotinoring() {
        showOverText = false
        
        if (appState.monitoring.isEnabled) {
            monitoringService.stopMonitoring()
        }
        else {
            if (appState.userData.allowedIps.isEmpty) {
                showNoOneAllowedIpDialog()
            }
            else {
                monitoringService.startMonitoring()
            }
        }
    }
    
    private func showNoOneAllowedIpDialog() {
        let showDialog = !appState.views.shownWindows
            .contains(where: {$0 == Constants.windowIdNoOneAllowedIpDialog})
        
        if showDialog {
            openWindow(id: Constants.windowIdNoOneAllowedIpDialog)
        }

    }
    
    // MARK: Inner types
    
    private struct MonitoringStatusControlData {
        let text: String
        let color: Color
        let hintText: String
    }
}

#Preview {
    MonitoringStatusView().environmentObject(AppState())
}
