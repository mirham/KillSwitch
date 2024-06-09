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
                MonitoringStatusView().environmentObject(monitoringService)
                Spacer()
                NetworkStatusView().environmentObject(networkStatusService)
                Spacer()
                    .frame(minHeight: 30)
                NetworkInterfacesView().environmentObject(networkStatusService)
                NetworkCapabilitesView().environmentObject(networkStatusService)
            }
            .navigationSplitViewColumnWidth(210)
        } content: {
            VStack{
                HStack{
                    ToggleMonitoringView().environmentObject(monitoringService)
                    ToggleNetworkView().environmentObject(networkStatusService)
                    ToggleKeepRunningView.init()
                }
                .padding()
                VStack{
                    LogView.init()
                }
            }
            .navigationSplitViewColumnWidth(min: 400, ideal: 400)
        } detail: {
            AllowedAddressesView
                .init()
                .navigationSplitViewColumnWidth(250)
        }.onAppear(perform: {
            appManagementService.setToTopMainView()
        }).onDisappear(perform: {
            appManagementService.isMainViewShowed = false
        }).frame(minHeight: 600)
    }
}

#Preview {
    MainView()
}
