//
//  ContentView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var monitoringService: MonitoringService
    @EnvironmentObject var networkStatusService: NetworkStatusService
    @EnvironmentObject var appManagementService: AppManagementService
    
    var body: some View {
        NavigationSplitView {
            VStack{
                CurrentIpView()
                    .environmentObject(monitoringService)
                    .environmentObject(networkStatusService)
                    .padding(.top)
                Spacer()
                    .frame(height: 30)
                MonitoringStatusView()
                    .environmentObject(monitoringService)
                    .padding(.top)
                NetworkStatusView()
                    .environmentObject(networkStatusService)
                    .padding(.top)
                Spacer()
                    .frame(minHeight: 30)
                NetworkInterfacesView()
                    .environmentObject(networkStatusService)
                // NetworkCapabilitesView()
                //    .environmentObject(networkStatusService)
            }
            .navigationSplitViewColumnWidth(220)
        } detail: {
            VStack{
                LogView.init()
            }
            .navigationSplitViewColumnWidth(min: 550, ideal: 550)
        }.onAppear(perform: {
            appManagementService.setViewToTop(viewName: Constants.windowIdMain)
        })
        .onDisappear(perform: {
            appManagementService.isMainViewShowed = false
        })
        .frame(minHeight: 500)
        .toolbar(content: {
            SettingsButtonView()
                .environmentObject(appManagementService)
                .padding(.trailing)
        })
    }
}

#Preview {
    MainView()
}
