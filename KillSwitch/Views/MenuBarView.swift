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
    @Environment(\.dismiss) var dismiss
    
    private var launchAgentService = LaunchAgentService.shared
    
    @State private var overShowText = false
    @State private var overQuitText = false
    
    var body: some View {
        VStack{
            CurrentIpView()
                .environmentObject(appState)
                .scaleEffect(Constants.memuBarScaleCurrentIp)
            HStack{
                MonitoringStatusView()
                    .environmentObject(appState)
                    .scaleEffect(Constants.memuBarScaleToggles)
                NetworkStatusView()
                    .environmentObject(appState)
                    .scaleEffect(Constants.memuBarScaleToggles)
                ProcessesStatusView()
                    .environmentObject(appState)
                    .scaleEffect(Constants.memuBarScaleToggles)
            }
            Spacer()
                .frame(height: 5)
            HStack {
                Button(Constants.show, systemImage: Constants.iconWindow) {
                    showButtonClickHandler()
                }
                .withMenuBarButtonStyle(bold: overShowText, color: overShowText ? .blue : .gray)
                .onHover(perform: { hovering in
                    overShowText = hovering
                })
                Spacer()
                    .frame(width: 20)
                Button(Constants.quit, systemImage: Constants.iconQuit) {
                    quitButtonClickHandler()
                }
                .withMenuBarButtonStyle(bold: overQuitText, color: overQuitText ? .red : .gray)
                .onHover(perform: { hovering in
                    overQuitText = hovering
                })
            }
        }
        .onAppear(perform: {
            appState.views.isStatusBarViewShown = true
        })
        .onDisappear(perform: {
            appState.views.isStatusBarViewShown = false
        })
    }
    
    // MARK: Private functions
    
    private func showButtonClickHandler() {
        if(!appState.views.isMainViewShown){
            openWindow(id: Constants.windowIdMain)
        }
        AppHelper.activateView(viewId: Constants.windowIdMain, simple: false)
        dismiss()
    }
    
    private func quitButtonClickHandler() {
        launchAgentService.apply()
        NSApplication.shared.terminate(nil)
    }
}

private extension Button {
    func withMenuBarButtonStyle(bold: Bool, color: Color) -> some View {
        self.buttonStyle(.plain)
            .focusEffectDisabled()
            .foregroundColor(color)
            .bold(bold)
    }
}

#Preview {
    MenuBarView().environmentObject(AppState())
}
