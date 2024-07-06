//
//  MenuBarView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import SwiftUI

struct MenuBarView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    
    private var launchAgentService = LaunchAgentService.shared
    
    @State private var showOverText = false
    @State private var quitOverText = false
    
    var body: some View {
        VStack{
            CurrentIpView()
                .environmentObject(appState)
            HStack{
                MonitoringStatusView()
                    .environmentObject(appState)
                    .padding()
                NetworkStatusView()
                    .environmentObject(appState)
                    .padding()
                ProcessesStatusView()
                    .environmentObject(appState)
                    .padding()
            }
            Spacer()
                .frame(height: 5)
            HStack {
                Button(Constants.show, systemImage: Constants.iconWindow) {
                    showButtonClickHandler()
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
                Button(Constants.quit, systemImage: Constants.iconQuit) {
                    launchAgentService.apply()
                    NSApplication.shared.terminate(nil)
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
            appState.views.isStatusBarViewShowed = true
        })
        .onDisappear(perform: {
            appState.views.isStatusBarViewShowed = false
        })
    }
    
    // MARK: Private functions
    
    private func showButtonClickHandler(){
        if(!appState.views.isMainViewShowed){
            openWindow(id: Constants.windowIdMain)
            appState.views.isMainViewShowed = true
        }
    }
}

#Preview {
    MenuBarView().environmentObject(AppState())
}
