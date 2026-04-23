//
//  MenuBarView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import SwiftUI
import Factory

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    
    @Injected(\.launchAgentService) private var launchAgentService
    
    @State private var isShowButtonHovering = false
    @State private var isQuitButtonHovering = false
    
    var body: some View {
        VStack {
            CurrentIpView()
                .environmentObject(appState)
                .scaleEffect(Constants.menuBarScaleCurrentIp)
            
            HStack(spacing: 10) {
                MonitoringStatusView()
                    .environmentObject(appState)
                    .scaleEffect(Constants.menuBarScaleToggles)
                NetworkStatusView()
                    .environmentObject(appState)
                    .scaleEffect(Constants.menuBarScaleToggles)
                ProcessesStatusView()
                    .environmentObject(appState)
                    .scaleEffect(Constants.menuBarScaleToggles)
            }
            Spacer()
                .frame(height: 5)
            HStack {
                Button(Constants.show, systemImage: Constants.iconWindow) {
                    handleShowButtonClick()
                }
                .withMenuBarButtonStyle(
                    isHovering: isShowButtonHovering,
                    color: isShowButtonHovering ? .blue : .gray
                )
                .onHover { isShowButtonHovering = $0 }
                Spacer()
                    .frame(width: 20)
                Button(Constants.quit, systemImage: Constants.iconQuit) {
                    handleQuitButtonClick()
                }
                .withMenuBarButtonStyle(
                    isHovering: isQuitButtonHovering,
                    color: isQuitButtonHovering ? .red : .gray
                )
                .onHover { isQuitButtonHovering = $0 }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .onAppear {
            appState.views.shownWindows
                .append(Constants.windowIdMenuBar)
        }
        .onDisappear {
            appState.views.shownWindows
                .removeAll { $0 == Constants.windowIdMenuBar }
        }
    }
    
    // MARK: Private functions
    
    private func handleShowButtonClick() {
        let mainWindowNotShown = !appState.views.shownWindows
            .contains(where: { $0 == Constants.windowIdMain })
        
        if mainWindowNotShown {
            openWindow(id: Constants.windowIdMain)
        }
        
        AppHelper.activateView(
            viewId: Constants.windowIdMain,
            simple: false)
        
        dismiss()
    }
    
    private func handleQuitButtonClick() {
        launchAgentService.apply()
        NSApplication.shared.terminate(nil)
    }
}

private extension Button {
    func withMenuBarButtonStyle(
        isHovering: Bool,
        color: Color) -> some View {
        self.buttonStyle(.plain)
            .focusEffectDisabled()
            .foregroundColor(color)
    }
}

#Preview {
    MenuBarView().environmentObject(AppState())
}
