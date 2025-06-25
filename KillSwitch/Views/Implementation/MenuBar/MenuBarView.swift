//
//  MenuBarView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import SwiftUI
import Factory

struct MenuBarView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) var dismiss
    
    @Injected(\.launchAgentService) private var launchAgentService
    
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
                    handleShowButtonClick()
                }
                .withMenuBarButtonStyle(bold: overShowText, color: overShowText ? .blue : .gray)
                .onHover(perform: { hovering in
                    overShowText = hovering
                })
                Spacer()
                    .frame(width: 20)
                Button(Constants.quit, systemImage: Constants.iconQuit) {
                    handleQuitButtonClick()
                }
                .withMenuBarButtonStyle(bold: overQuitText, color: overQuitText ? .red : .gray)
                .onHover(perform: { hovering in
                    overQuitText = hovering
                })
            }
        }
        .onAppear(perform: {
            appState.views.shownWindows.append(Constants.windowIdMenuBar)
        })
        .onDisappear(perform: {
            appState.views.shownWindows.removeAll(where: {$0 == Constants.windowIdMenuBar})
        })
    }
    
    // MARK: Private functions
    
    private func handleShowButtonClick() {
        let requireOpenWindow = !appState.views.shownWindows
            .contains(where: {$0 == Constants.windowIdMain})
        
        if requireOpenWindow {
            openWindow(id: Constants.windowIdMain)
        }
        
        AppHelper.activateView(viewId: Constants.windowIdMain, simple: false)
        dismiss()
    }
    
    private func handleQuitButtonClick() {
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
