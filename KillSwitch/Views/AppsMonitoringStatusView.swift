//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct AppsMonitoringStatusView: View {
    @EnvironmentObject var computerManagementService : ComputerManagementService
    
    var body: some View {
        Section() {
            VStack{
                Text("Apps".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text(computerManagementService.activeProcessesToClose.count.description)
                    .frame(width: 60, height: 60)
                    .background(.yellow)
                    .foregroundColor(.black.opacity(0.5))
                    .font(.system(size: 18))
                    .bold()
                    .clipShape(Circle())
                    .onTapGesture(perform: {
                        computerManagementService.killActiveProcesses()
                    })
                    .pointerOnHover()
            }
        }.isHidden(hidden:computerManagementService.activeProcessesToClose.isEmpty, remove: true)
    }
}

#Preview {
    MonitoringStatusView()
}
