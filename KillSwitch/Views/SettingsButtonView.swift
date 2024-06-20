//
//  ToggleNetworkView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import SwiftUI

struct SettingsButtonView: View {
    let appManagementService = AppManagementService.shared
    
    @State private var showOverText = false
    @State private var quitOverText = false

    var body: some View {
        Section {
            Button(String(), systemImage: "gearshape.2") {
                appManagementService.showSettingsView()
            }
            .buttonStyle(.plain)
            .foregroundColor(showOverText ? .blue : .primary)
            .bold(showOverText)
            .focusEffectDisabled()
            .onHover(perform: { hovering in
                showOverText = hovering
            })
            .help(Constants.settings)
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
}

#Preview {
    ToggleNetworkView()
}
