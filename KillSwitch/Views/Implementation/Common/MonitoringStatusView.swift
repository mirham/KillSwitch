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
    
    private var status: MonitoringStatusType {
        appState.monitoring.isEnabled
        ? .on
        : .off
    }
    private var isEnabled: Bool { appState.monitoring.isEnabled }
    private var hintText: String {
        isEnabled
        ? Constants.hintClickToDisableMonitoring
        : Constants.hintClickToEnableMonitoring
    }
    
    var body: some View {
        StatusCard(
            imageName: Constants.iconMonitoring,
            title: Constants.monitoring,
            cardBackgroundColor: status.backgroundColor,
            cardBorderColor: status.borderColor
        ) {
            statusView
        } trailingContent: {
            toggleView
        }
        .focusEffectDisabled()
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var statusView: some View {
        HStack(alignment: .center, spacing: 3) {
            Circle()
                .fill(status.color)
                .frame(width: 10, height: 10)
            Text(status.description)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(status.color)
        }
    }
    
    @ViewBuilder
    private var toggleView: some View {
        Toggle(String(), isOn: Binding(
            get: { isEnabled },
            set: { _ in toggleMonitoring() }
        ))
        .toggleStyle(.switch)
        .focusable(false)
        .labelsHidden()
        .onTapGesture(perform: toggleMonitoring)
        .pointerOnHover()
        .onHover { hovering in
            isHovering = hovering && controlActiveState == .key
        }
        .help(hintText)
    }
    
    // MARK: Private functions
    
    private func toggleMonitoring() {
        isHovering = false
        
        if appState.monitoring.isEnabled {
            monitoringService.stopMonitoring()
        } else {
            guard !appState.userData.allowedIps.isEmpty
            else {
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
}

#Preview {
    MonitoringStatusView().environmentObject(AppState())
}
