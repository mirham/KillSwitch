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
    
    @Environment(\.dismiss) private var dismiss
    
    @Injected(\.launchAgentService) private var launchAgentService
    @Injected(\.windowManager) private var windowManager
    
    @State private var isShowButtonHovering = false
    @State private var isQuitButtonHovering = false
    
    var body: some View {
        VStack(spacing: 3) {
            CurrentIpView()
                .scaleEffect(Constants.menuBarScaleCurrentIp)
            MonitoringStatusView()
                .scaleEffect(Constants.menuBarScaleCurrentIp)
            NetworkStatusView()
                .scaleEffect(Constants.menuBarScaleCurrentIp)
            ProcessesStatusView()
                .scaleEffect(Constants.menuBarScaleCurrentIp)
            Divider()
                .padding(.top, 5)
                .padding(.leading, 5)
                .padding(.trailing, 5)
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
                Divider()
                    .padding(.horizontal)
                Spacer()
                Button(Constants.quit, systemImage: Constants.iconQuit) {
                    handleQuitButtonClick()
                }
                .withMenuBarButtonStyle(
                    isHovering: isQuitButtonHovering,
                    color: isQuitButtonHovering ? .red : .gray
                )
                .onHover { isQuitButtonHovering = $0 }
            }
            .frame(height: 30)
        }
        .frame(width: 200)
        .padding(5)
    }
    
    // MARK: Private functions
    
    private func handleShowButtonClick() {
        windowManager.open(name: .main, onTop: appState.userData.onTopOfAllWindows)
        
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
            .padding(5)
    }
}

#Preview {
    MenuBarView().environmentObject(AppState())
}
