//
//  ToggleNetworkView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct SettingsButtonView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @State private var showOverText = false
    @State private var quitOverText = false

    var body: some View {
        Section {
            Button("Settings", systemImage: "gearshape.2") {
                showSettingsWindow()
            }
            .buttonStyle(.plain)
            .foregroundColor(showOverText && controlActiveState == .key ? .blue : .primary)
            .bold(showOverText)
            .focusEffectDisabled()
            .popover(isPresented: $showOverText, content: {
                Text(Constants.settings)
                    .padding()
                    .interactiveDismissDisabled()
            })
            .onHover(perform: { hovering in
                showOverText = hovering && controlActiveState == .key
            })
        }
        .font(.system(size: 18))
        .opacity(controlActiveState == .key ? 1 : 0.6)
        .pointerOnHover()
    }
    
    // MARK: Private functions
    
    private func showSettingsWindow() {
        if(!appState.views.isSettingsViewShowed){
            openWindow(id: Constants.windowIdSettings)
            appState.views.isSettingsViewShowed = true
        }
    }
}

#Preview {
    SettingsButtonView()
}
