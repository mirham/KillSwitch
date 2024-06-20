//
//  ToggleNetworkView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import SwiftUI

struct SettingsButtonView: View {
    @Environment(\.openWindow) private var openWindow
    
    @EnvironmentObject var appManagementService: AppManagementService
    
    @State private var showOverText = false
    @State private var quitOverText = false

    var body: some View {
        Section {
            Button(String(), systemImage: "gearshape.2") {
                showSettingsWindow()
            }
            .buttonStyle(.plain)
            .foregroundColor(showOverText ? .blue : .primary)
            .bold(showOverText)
            .focusEffectDisabled()
            .help(Constants.settings)
            .onHover(perform: { hovering in
                showOverText = hovering
            })
        }
        .font(.system(size: 21))
        .onHover(perform: { hovering in
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        })
    }
    
    private func showSettingsWindow() {
        if(!appManagementService.isSettingsViewShowed){
            openWindow(id: Constants.windowIdSettings)
            appManagementService.showSettingsView()
        }
    }
}

#Preview {
    ToggleNetworkView()
}
