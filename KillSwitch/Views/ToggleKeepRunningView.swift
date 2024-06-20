//
//  ToggleMonitoringView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import SwiftUI

struct ToggleKeepRunningView: View {
    let appManagementService = AppManagementService.shared

    @State private var isOn = false

    var body: some View {
        Section {
            Toggle("Keep running", isOn: .init(
                get: { isOn },
                set: { _, _ in if isOn {
                        isOn = !appManagementService.uninstallLaunchAgent()
                    }
                    else {
                        isOn = appManagementService.installLaunchAgent()
                    }
                }))
                .toggleStyle(CheckToggleStyle())
                .onHover(perform: { hovering in
                    if hovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                })
        }
        .font(.system(size: 18))
        .onAppear {
            let initState  = appManagementService.isLaunchAgentInstalled
            isOn = initState
        }
    }
}

#Preview {
    ToggleMonitoringView()
}
