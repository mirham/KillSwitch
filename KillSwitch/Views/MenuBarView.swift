//
//  MenuBarWindowView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import SwiftUI

struct MenuBarView : View {   
    @Environment(\.openWindow) private var openWindow
    
    @EnvironmentObject var appManagementService: AppManagementService
    @EnvironmentObject var monitoringService: MonitoringService
    @EnvironmentObject var networkStatusService: NetworkStatusService
    @EnvironmentObject var processesService: ProcessesService
    
    @State private var showOverText = false
    @State private var quitOverText = false
    
    var body: some View {
        VStack{
            CurrentIpView()
                .environmentObject(monitoringService)
                .environmentObject(networkStatusService)
            HStack{
                MonitoringStatusView()
                    .environmentObject(monitoringService)
                    .padding()
                NetworkStatusView()
                    .environmentObject(networkStatusService)
                    .padding()
                ProcessesStatusView()
                    .environmentObject(processesService)
                    .padding()
            }
            Spacer()
                .frame(height: 5)
            HStack {
                Button("Show", systemImage: "macwindow") {
                    showMainWindow()
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
        .onAppear(perform: {
            appManagementService.isStatusBarViewShowed = true
        })
        .onDisappear(perform: {
            print("hidden")
            appManagementService.isStatusBarViewShowed = false
        })
    }
    
    // MARK: Private functions
    
    private func showMainWindow(){
        if(!appManagementService.isMainViewShowed){
            openWindow(id: Constants.windowIdMain)
            appManagementService.showMainView()
        }
    }
}

#Preview {
    MenuBarView()
}
