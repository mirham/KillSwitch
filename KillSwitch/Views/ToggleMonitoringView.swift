//
//  ToggleMonitoringView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import SwiftUI

struct ToggleMonitoringView: View {
    @EnvironmentObject var monitoringService : MonitoringService

    var body: some View {
        Section {
            Toggle("Monitoring", isOn: Binding(
                get: { monitoringService.isMonitoringEnabled },
                set: {
                    if($0){
                        monitoringService.startMonitoring()
                    }
                    else{
                        monitoringService.stopMonitoring()
                    }
                }
            ))
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
    }
}

#Preview {
    ToggleMonitoringView()
}
