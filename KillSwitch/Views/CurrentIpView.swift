//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftUI

struct CurrentIpView: View {
    @EnvironmentObject var monitoringService : MonitoringService
    
    var body: some View {
        Section() {
            VStack{
                Text("Current IP".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                Text(monitoringService.currentIpAddress)
                    .font(.largeTitle)
            }
            .padding()
        }
    }
}

#Preview {
    CurrentIpView()
}
