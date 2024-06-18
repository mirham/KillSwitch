//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftUI

struct MonitoringStatusView: View {
    @EnvironmentObject var monitoringService : MonitoringService
    
    var body: some View {
        Section() {
            VStack{
                Text("Monitoring status".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                switch monitoringService.isMonitoringEnabled {
                    case true:
                        Text("On".uppercased())
                            .frame(width: 60, height: 60)
                            .background(.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    case false:
                        Text("Off".uppercased())
                            .frame(width: 60, height: 60)
                            .background(.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    MonitoringStatusView()
}
