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
