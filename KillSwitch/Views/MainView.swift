//
//  ContentView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct MainView: View {
    let appManagementService = AppManagementService.shared
    
    @EnvironmentObject var monitoringService: MonitoringService
    @EnvironmentObject var networkStatusService: NetworkStatusService

    
    var body: some View {
        NavigationSplitView {
            VStack{
                CurrentIpView()
                    .environmentObject(monitoringService)
                Spacer()
                    .frame(minHeight: 20)
                MonitoringStatusView()
                    .environmentObject(monitoringService)
                Spacer()
                    .frame(minHeight: 20)
                NetworkStatusView()
                    .environmentObject(networkStatusService)
                Spacer()
                    .frame(minHeight: 30)
                NetworkInterfacesView()
                    .environmentObject(networkStatusService)
                NetworkCapabilitesView()
                    .environmentObject(networkStatusService)
            }
            .navigationSplitViewColumnWidth(220)
        } detail: {
            VStack{
                HStack{
                    Spacer()
                    ToggleMonitoringView()
                        .environmentObject(monitoringService)
                    ToggleNetworkView()
                        .environmentObject(networkStatusService)
                    ToggleKeepRunningView.init()
                    Spacer()
                    SettingsButtonView()
                }
                .padding()
                VStack{
                    LogView.init()
                }
            }
            .navigationSplitViewColumnWidth(min: 600, ideal: 600)
        }.onAppear(perform: {
            appManagementService.setViewToTop(viewName: "main-view")
        })
        .onDisappear(perform: {
            appManagementService.isMainViewShowed = false
        })
        .frame(minHeight: 600)
    }
}

#Preview {
    MainView()
}
