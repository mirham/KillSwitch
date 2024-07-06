//
//  SettingsButtonView.swift
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
            Button(Constants.settings, systemImage: Constants.iconSettings) {
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
        .opacity(getViewOpacity(state: controlActiveState))
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
    SettingsButtonView().environmentObject(AppState())
}
