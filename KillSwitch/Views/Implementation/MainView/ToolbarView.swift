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
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.loggingService) private var loggingService
    
    @State private var hoveredButton: ToolbarButtonType?
    
    var body: some View {
        Group {
            Spacer()
            toolbarButton(
                for: .copy,
                title: Constants.toolbarCopyLog,
                icon: Constants.iconCopyLog,
                action: { loggingService.copy() }
            )
            .padding(.leading, 10)
            toolbarButton(
                for: .clear,
                title: Constants.toolbarClearLog,
                icon: Constants.iconClearLog,
                action: { loggingService.clear() }
            )
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
        openWindowIfNeeded(id: Constants.windowIdSettings)
        AppHelper.activateView(viewId: Constants.windowIdSettings)
    }
    
    private func showInfoWindow() {
        openWindowIfNeeded(id: Constants.windowIdInfo)
        AppHelper.activateView(viewId: Constants.windowIdInfo)
    }
    
    private func openWindowIfNeeded(id: String) {
        let windowAlreadyShown = appState.views.shownWindows
            .contains(where: { $0 == id })
        
        guard !windowAlreadyShown
        else { return }
        
        openWindow(id: id)
    }
    
    // MARK: Inner types
    
    private enum ToolbarButtonType {
        case copy, clear, settings, info
    }
}
#Preview {
    ToolbarView().environmentObject(AppState())
}
