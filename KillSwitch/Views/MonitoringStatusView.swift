//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct MonitoringStatusView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) private var controlActiveState
    
    @State private var showOverText = false
    
    private let monitoringService = MonitoringService.shared
    
    var body: some View {
        Section() {
            VStack{
                Text("Monitoring".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text((appState.monitoring.isEnabled ? "On": "Off").uppercased())
                    .frame(width: 60, height: 60)
                    .background(appState.monitoring.isEnabled ? .green : .red)
                    .foregroundColor(.black.opacity(0.5))
                    .font(.system(size: 18))
                    .bold()
                    .clipShape(Circle())
                    .onTapGesture(perform: toggleMotinoring)
                    .pointerOnHover()
                    .onHover(perform: { hovering in
                        showOverText = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverText, arrowEdge: .trailing, content: {
                        Text("Click to \(appState.monitoring.isEnabled ? "disable" : "enable" ) monitoring")
                            .padding()
                            .interactiveDismissDisabled()
                    })
            }
        }
        .frame(width: 110, height: 90)
    }
    
    // MARK: Private functions
    
    private func toggleMotinoring() {
        showOverText = false
        
        if (appState.monitoring.isEnabled) {
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
