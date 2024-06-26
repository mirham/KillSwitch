//
//  ToggleNetworkView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct SettingsButtonView : View {
    @Environment(\.openWindow) private var openWindow
    
    @EnvironmentObject var appManagementService: AppManagementService
    
    @State private var showOverText = false
    @State private var quitOverText = false

    var body: some View {
        Section {
            Button("Settings", systemImage: "gearshape.2") {
                showSettingsWindow()
            }
            .buttonStyle(.plain)
            .foregroundColor(showOverText ? .blue : .primary)
            .bold(showOverText)
            .focusEffectDisabled()
            .popover(isPresented: $showOverText, content: {
                Text(Constants.settings)
                    .padding()
                    .interactiveDismissDisabled()
            })
            .onHover(perform: { hovering in
                showOverText = hovering
            })
        }
        .font(.system(size: 18))
        .pointerOnHover()
    }
    
    // MARK: Private functions
    
    private func showSettingsWindow() {
        if(!appManagementService.isSettingsViewShowed){
            openWindow(id: Constants.windowIdSettings)
            appManagementService.showSettingsView()
        }
    }
}

#Preview {
    SettingsButtonView()
}
