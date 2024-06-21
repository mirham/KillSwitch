//
//  MenuBarStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation
import SwiftUI

struct MenuBarStatusView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var monitoringService: MonitoringService
    @EnvironmentObject var networkStatusService : NetworkStatusService
    
    var body: some View {
        HStack{
            Image(renderMenuBarStatusImage(), scale: 1, label: Text(String()))
        }
    }
    
    // MARK: Private functions
    
    @MainActor
    private func renderMenuBarStatusImage() -> CGImage{
        let isMonitoringEnabled = monitoringService.isMonitoringEnabled
        
        let title =
        Text(Image(systemName: isMonitoringEnabled
                   ? "shield.lefthalf.filled.badge.checkmark"
                   : "shield.lefthalf.filled.slash"))
        .foregroundColor(isMonitoringEnabled ? .green : .red)
            .font(.system(size: 16.0))
        + Text((isMonitoringEnabled ? " On" : "Off").uppercased())
            .font(.system(size: 16.0))
            .bold()
            .foregroundColor(isMonitoringEnabled ? .green : .red)
        // Text(networkStatusService.currentIpAddressInfo?.countryName.uppercased() ?? String())
        //    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        let renderer = ImageRenderer(content: title)
        let result = renderer.cgImage
        
        return result!
    }
    
}

#Preview {
    MenuBarStatusView()
}

