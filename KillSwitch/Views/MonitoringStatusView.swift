//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct MonitoringStatusView : View {
    @EnvironmentObject var monitoringService : MonitoringService
    
    @State private var showOverText = false
    
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
                    .onTapGesture(perform: toggleMotinoring)
                    .pointerOnHover()
                    .onHover(perform: { hovering in
                        showOverText = hovering
                    })
                    .popover(isPresented: $showOverText, content: {
                        Text("Click to \(monitoringService.isMonitoringEnabled ? "disable" : "enable" ) monitoring")
                            .padding()
                            .interactiveDismissDisabled()
                    })
            }
        }
    }
    
    // MARK: Private functions
    
    private func toggleMotinoring() {
        showOverText = false
        
        if (monitoringService.isMonitoringEnabled) {
            monitoringService.stopMonitoring()
        }
        else {
            monitoringService.startMonitoring()
        }
    }
}

#Preview {
    MonitoringStatusView()
}
