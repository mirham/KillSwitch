//
//  ToolbarView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI
import Factory

struct ToolbarView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.loggingService) private var loggingService
    @Injected(\.windowManager) private var windowManager
    
    @State private var hoveredButton: ToolbarButtonType?
    
    var body: some View {
        Group {
            Spacer()
            toolbarButton(
                for: .logsFolder,
                title: Constants.toolbarOpenLogsFolder,
                icon: Constants.iconFolder,
                action: { loggingService.openLogsFolder() }
            )
            .padding(.leading, 10)
            toolbarButton(
                for: .settings,
                title: Constants.toolbarSettings,
                icon: Constants.iconSettings,
                action: showSettingsWindow
            )
            toolbarButton(
                for: .info,
                title: Constants.toolbarInfo,
                icon: Constants.iconInfo,
                action: showInfoWindow
            )
            .padding(.trailing, -10)
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private func toolbarButton(
        for type: ToolbarButtonType,
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        ToolbarButton(
            title: title,
            systemImage: icon,
            isHovered: hoveredButton == type,
            activeState: controlActiveState,
            action: action
        )
        .onHover { hoveredButton = $0 ? type : nil }
        .help(title)
    }
    
    // MARK: Private functions
    
    private func showSettingsWindow() {
        windowManager.open(
            name: .settings,
            onTop: appState.userData.onTopOfAllWindows)
    }
    
    private func showInfoWindow() {
        windowManager.open(
            name: .info,
            onTop: appState.userData.onTopOfAllWindows)
    }
    
    // MARK: Inner types
    
    private enum ToolbarButtonType {
        case logsFolder, settings, info
    }
}
#Preview {
    ToolbarView().environmentObject(AppState())
}
