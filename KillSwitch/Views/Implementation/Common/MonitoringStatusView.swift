//
//  MonitoringStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Factory

struct MonitoringStatusView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.monitoringService) private var monitoringService
    
    @State private var isHovering = false
    
    private var monitoringStatusControlData: MonitoringStatusControlData {
        if appState.monitoring.isEnabled {
            return MonitoringStatusControlData(
                text: Constants.on,
                color: .green,
                hintText: Constants.hintClickToDisableMonitoring
            )
        } else {
            return MonitoringStatusControlData(
                text: Constants.off,
                color: .red,
                hintText: Constants.hintClickToEnableMonitoring
            )
        }
    }
    
    var body: some View {
        Section {
            VStack {
                Text(Constants.monitoring.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                monitoringStatusControl
            }
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var monitoringStatusControl: some View {
        let data = monitoringStatusControlData
        
        Text(data.text.uppercased())
            .frame(width: 60, height: 60)
            .background(data.color)
            .foregroundColor(.black.opacity(0.5))
            .font(.system(size: 18))
            .bold()
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.blue, lineWidth: isHovering ? 2 : 0)
            )
            .onTapGesture(perform: toggleMonitoring)
            .pointerOnHover()
            .onHover { hovering in
                isHovering = hovering && controlActiveState == .key
            }
            .popover(isPresented: $isHovering, arrowEdge: .trailing) {
                Text(data.hintText)
                    .padding()
                    .interactiveDismissDisabled()
            }
    }
    
    // MARK: Private functions
    
    private func toggleMonitoring() {
        isHovering = false
        
        if appState.monitoring.isEnabled {
            monitoringService.stopMonitoring()
        } else {
            guard !appState.userData.allowedIps.isEmpty else {
                showNoAllowedIpDialog()
                
                return
            }
            monitoringService.startMonitoring()
        }
    }
    
    private func showNoAllowedIpDialog() {
        let dialogAlreadyShown = appState.views.shownWindows
            .contains(where: { $0 == Constants.windowIdNoOneAllowedIpDialog })
        
        guard !dialogAlreadyShown
        else { return }
        
        openWindow(id: Constants.windowIdNoOneAllowedIpDialog)
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
