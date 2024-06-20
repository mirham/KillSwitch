//
//  MenuBarWindowView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import SwiftUI

struct MenuBarView: View {   
    @Environment(\.openWindow) private var openWindow
    
    @EnvironmentObject var monitoringService: MonitoringService
    @EnvironmentObject var networkStatusService: NetworkStatusService
    
    @State private var showOverText = false
    @State private var quitOverText = false
    
    let appManagementService = AppManagementService.shared
    
    var body: some View {
        VStack{
            CurrentIpView.init()
            HStack{
                MonitoringStatusView().environmentObject(monitoringService).padding()
                NetworkStatusView().environmentObject(networkStatusService).padding()
            }
            Spacer()
                .frame(height: 5)
            HStack{
                Button("Show", systemImage: "macwindow") {
                    appManagementService.showMainView()
                }
                .buttonStyle(.plain)
                .foregroundColor(showOverText ? .blue : .gray)
                .bold(showOverText)
                .focusEffectDisabled()
                .onHover(perform: { hovering in
                    showOverText = hovering
                })
                Spacer()
                    .frame(width: 20)
                Button("Quit", systemImage: "xmark.circle") {
                    appManagementService.quitApp()
                }
                .buttonStyle(.plain)
                .focusEffectDisabled()
                .bold(quitOverText)
                .foregroundColor(quitOverText ? .red : .gray)
                .onHover(perform: { hovering in
                    quitOverText = hovering
                })
            }
        }
    }
}

#Preview {
    MenuBarView()
}
