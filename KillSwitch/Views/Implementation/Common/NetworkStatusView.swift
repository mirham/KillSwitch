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
    
    private var networkStatusControlData: NetworkStatusControlData {
        switch appState.network.status {
            case .on:
                return NetworkStatusControlData(
                    text: appState.network.status.description,
                    color: .green,
                    action: { toggleNetwork(enable: false) },
                    hintText: Constants.hintClickToDisableNetwork
                )
                
            case .off:
                return NetworkStatusControlData(
                    text: appState.network.status.description,
                    color: .red,
                    action: { toggleNetwork(enable: true) },
                    hintText: Constants.hintClickToEnableNetwork
                )
                
            case .wait:
                return NetworkStatusControlData(
                    text: appState.network.status.description,
                    color: .yellow,
                    action: {},
                    hintText: nil
                )
                
            default:
                return NetworkStatusControlData(
                    text: Constants.na,
                    color: .gray,
                    action: {},
                    hintText: nil
                )
        }
    }
    
    var body: some View {
        Section {
            VStack {
                Text(Constants.network.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                networkStatusControl
            }
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var networkStatusControl: some View {
        let data = networkStatusControlData
        
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
            .onTapGesture(perform: data.action)
            .pointerOnHover()
            .onHover(perform: updateHoverState(for: data))
            .popover(isPresented: $isHovering, arrowEdge: .trailing) {
                if let hintText = data.hintText {
                    Text(hintText)
                        .padding()
                        .focusEffectDisabled()
                        .interactiveDismissDisabled()
                }
            }
    }
    
    // MARK: Private functions
    
    private func updateHoverState(
        for data: NetworkStatusControlData) -> (Bool) -> Void {
        return { hovering in
            isHovering = hovering
            && controlActiveState == .key
            && data.hintText != nil
        }
    }
    
    private func toggleNetwork(enable: Bool) {
        isHovering = false
        
        let physicalNetworkInterfaces = networkService.getPhysicalInterfaces()
        
        if enable {
            if appState.network.physicalNetworkInterfaces.count > 1 {
                showEnableNetworkDialog()
            } else {
                guard let firstInterface = appState.network.physicalNetworkInterfaces.first
                else { return }
                
                networkService.enableNetworkInterface(
                    interfaceName: firstInterface.name)
            }
        } else {
            for interface in physicalNetworkInterfaces {
                networkService.disableNetworkInterface(
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
    
    // MARK: Inner types
    
    private struct NetworkStatusControlData {
        let text: String
        let color: Color
        let action: () -> Void
        let hintText: String?
    }
}

#Preview {
    NetworkStatusView().environmentObject(AppState())
}
