//
//  ToolbarView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI
import Factory

struct ToolbarView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.loggingService) private var loggingService
    
    @State private var hoveredButton: ToolbarButtonType? = nil

    var body: some View {
        Group {
            Spacer()
            ToolbarButton(
                title: Constants.toolbarCopyLog,
                systemImage: Constants.iconCopyLog,
                isHovered: hoveredButton == .copy,
                activeState: controlActiveState
            ) {
                loggingService.copy()
            }
            .onHover { hoveredButton = $0 ? .copy : nil }
            .help(Constants.toolbarCopyLog)
            .padding(.leading, 10)
            
            ToolbarButton(
                title: Constants.toolbarClearLog,
                systemImage: Constants.iconClearLog,
                isHovered: hoveredButton == .clear,
                activeState: controlActiveState
            ) {
                loggingService.clear()
            }
            .onHover { hoveredButton = $0 ? .clear : nil }
            .help(Constants.toolbarClearLog)
            
            ToolbarButton(
                title: Constants.toolbarSettings,
                systemImage: Constants.iconSettings,
                isHovered: hoveredButton == .settings,
                activeState: controlActiveState
            ) {
                showSettingsWindow()
            }
            .onHover { hoveredButton = $0 ? .settings : nil }
            .help(Constants.toolbarSettings)
            
            ToolbarButton(
                title: Constants.toolbarInfo,
                systemImage: Constants.iconInfo,
                isHovered: hoveredButton == .info,
                activeState: controlActiveState
            ) {
                showInfoWindow()
            }
            .onHover { hoveredButton = $0 ? .info : nil }
            .help(Constants.toolbarInfo)
            .padding(.trailing, -10)
        }
    }
    
    // MARK: Private functions
    
    private func renderHint(hint: String) -> some View {
        let result = Text(hint)
            .padding()
            .interactiveDismissDisabled()
        
        return result
    }
    
    private func showSettingsWindow() {
        let requireOpenWindow = !appState.views.shownWindows
            .contains(where: {$0 == Constants.windowIdSettings})
        
        if requireOpenWindow {
            openWindow(id: Constants.windowIdSettings)
        }
        
        AppHelper.activateView(viewId: Constants.windowIdSettings)
    }
    
    private func showInfoWindow() {
        let requireOpenWindow = !appState.views.shownWindows
            .contains(where: {$0 == Constants.windowIdInfo})
        
        if requireOpenWindow {
            openWindow(id: Constants.windowIdInfo)
        }
        
        AppHelper.activateView(viewId: Constants.windowIdInfo)
    }
    
    // MARK: Inner types
    
    private enum ToolbarButtonType { case copy, clear, settings, info }
}

#Preview {
    ToolbarView().environmentObject(AppState())
}
