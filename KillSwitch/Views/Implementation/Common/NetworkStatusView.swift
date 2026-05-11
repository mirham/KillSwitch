//
//  NetworkStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI
import Factory

struct NetworkStatusView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.networkService) private var networkService
    
    @State private var isHovering = false
    
    private var status: NetworkStatusType { appState.network.status }
    private var userIntentOn: Bool { status == .on || status == .wait }
    private var hintText: String {
        switch status {
            case .on: return Constants.hintClickToDisableNetwork
            case .off: return Constants.hintClickToEnableNetwork
            default: return String()
        }
    }
    
    var body: some View {
        StatusCard(
            imageName: appState.network.firstPhysicalInterface?.type.icon
                ?? NetworkInterfaceType.unknown.icon,
            title: Constants.network,
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
    
    private var toggleView: some View {
        Toggle(String(), isOn: Binding(
            get: { userIntentOn },
            set: { newValue in Task { await toggleNetworkAsync(enable: newValue) } }
        ))
        .toggleStyle(.switch)
        .focusable(false)
        .labelsHidden()
        .disabled(status == .wait)
        .pointerOnHover()
        .onHover(perform: updateHoverState)
        .help(hintText)
    }
    
    // MARK: Private functions
    
    private func updateHoverState(_ hovering: Bool) {
        isHovering = hovering
        && controlActiveState == .key
        && hintText != String()
    }
    
    private func toggleNetworkAsync(enable: Bool) async {
        isHovering = false
        
        let physicalNetworkInterfaces = networkService.getPhysicalInterfaces()
        
        if enable {
            if appState.network.physicalNetworkInterfaces.count > 1 {
                showEnableNetworkDialog()
            } else {
                guard let firstInterface = appState.network.physicalNetworkInterfaces.first
                else { return }
                
                await networkService.enableNetworkInterfaceAsync(
                    interfaceName: firstInterface.name)
            }
        } else {
            for interface in physicalNetworkInterfaces {
                await networkService.disableNetworkInterfaceAsync(
                    interfaceName: interface.name)
            }
        }
    }
    
    private func showEnableNetworkDialog() {
        let dialogAlreadyShown = appState.views.shownWindows
            .contains(where: { $0 == Constants.windowIdEnableNetworkDialog })
        
        guard !dialogAlreadyShown
        else { return }
        
        openWindow(id: Constants.windowIdEnableNetworkDialog)
    }
}

#Preview {
    NetworkStatusView().environmentObject(AppState())
}
