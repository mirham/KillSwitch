//
//  NetworkStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI
import Factory

struct NetworkStatusView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.networkService) private var networkService
    
    @State private var showOverText = false

    var body: some View {
        Section {
            VStack {
                Text(Constants.network.uppercased())
                    .font(.title3)
                renderNetworkStatusControl()
            }
        }
        .frame(width: 110, height: 90)
    }
    
    // MARK: Private functions
    
    private func renderNetworkStatusControl() -> some View {
        let data = getNetworkStatusControlData()
        
        let result = Text(data.text.uppercased())
            .frame(width: 60, height: 60)
            .background(data.color)
            .foregroundColor(.black.opacity(0.5))
            .font(.system(size: 18))
            .bold()
            .clipShape(Circle())
            .overlay(content: { Circle().stroke(.blue, lineWidth: showOverText ? 2 : 0) })
            .onTapGesture(perform: data.action)
            .pointerOnHover()
            .onHover(perform: { hovering in
                showOverText = hovering && controlActiveState == .key && data.hintText != nil
            })
            .popover(isPresented: $showOverText, arrowEdge: .trailing, content: {
                Text(data.hintText!)
                    .padding()
                    .focusEffectDisabled()
                    .interactiveDismissDisabled()
            })
        
        return result
    }
    
    private func getNetworkStatusControlData() -> NetworkStatusControlData {
        switch appState.network.status {
            case .on:
                return NetworkStatusControlData(
                    text: appState.network.status.description,
                    color: .green,
                    action: { toggleNetwork(enable: false) },
                    hintText: Constants.hintClickToDisableNetwork)
            case .off:
                return NetworkStatusControlData(
                    text: appState.network.status.description,
                    color: .red,
                    action: { toggleNetwork(enable: true) },
                    hintText: Constants.hintClickToEnableNetwork)
            case .wait:
                return NetworkStatusControlData(
                    text: appState.network.status.description,
                    color: .yellow,
                    action: {})
            default:
                return NetworkStatusControlData(
                    text:Constants.na,
                    color: .gray,
                    action: {})
        }
    }
    
    private func toggleNetwork(enable : Bool) {
        showOverText = false
        
        let physicalNetworkInterfaces = networkService.getPhysicalInterfaces()
        
        if (enable) {
            if (appState.network.physicalNetworkInterfaces.count > 1) {
                showEnableNetworkDialog()
            }
            else {
                networkService.enableNetworkInterface(interfaceName: appState.network.physicalNetworkInterfaces.first!.name)
            }
        }
        else {
            for interface in physicalNetworkInterfaces {
                networkService.disableNetworkInterface(interfaceName: interface.name)
            }
        }
    }
    
    // MARK: Private functions
    
    private func showEnableNetworkDialog() {
        if(!appState.views.shownWindows.contains(where: {$0 == Constants.windowIdEnableNetworkDialog})){
            openWindow(id: Constants.windowIdEnableNetworkDialog)
        }
    }
    
    // MARK: Inner types
    
    private struct NetworkStatusControlData {
        let text: String
        let color: Color
        var action: () -> Void
        var hintText: String?
    }
}

#Preview {
    NetworkStatusView().environmentObject(AppState())
}
