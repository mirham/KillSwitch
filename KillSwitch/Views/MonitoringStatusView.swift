//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct MonitoringStatusView: View {
    @EnvironmentObject var monitoringService : MonitoringService
    
    var body: some View {
        Section() {
            VStack{
                Text("Monitoring".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text((monitoringService.isMonitoringEnabled ? "On": "Off").uppercased())
                    .frame(width: 60, height: 60)
                    .background(monitoringService.isMonitoringEnabled ? .green : .red)
                    .foregroundColor(.black.opacity(0.5))
                    .font(.system(size: 18))
                    .bold()
                    .clipShape(Circle())
                    .onTapGesture(perform: {
                        if (monitoringService.isMonitoringEnabled) {
                            monitoringService.stopMonitoring()
                        }
                        else {
                            monitoringService.startMonitoring()
                        }
                        
                    })
                    .pointerOnHover()
            }
        }
    }
}

#Preview {
    MonitoringStatusView()
}
