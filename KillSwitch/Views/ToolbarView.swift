//
//  ToolbarView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct ToolbarView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.controlActiveState) private var controlActiveState
    
    @State private var showOverSettings = false
    @State private var showOverCopyLog = false
    @State private var showOverClearLog = false
    @State private var showOverInfo = false

    var body: some View {
        Section {
            Spacer()
            Button(Constants.toolbarCopyLog, systemImage: Constants.iconCopyLog) {
                Log.copy()
            }
            .withToolbarButtonStyle(showOver: showOverCopyLog, activeState: controlActiveState)
            .popover(isPresented: $showOverCopyLog, content: {
                renderHint(hint: Constants.toolbarCopyLog)
            })
            .onHover(perform: { hovering in
                showOverCopyLog = hovering && controlActiveState == .key
            })
            Button(Constants.toolbarClearLog, systemImage: Constants.iconClearLog) {
                Log.clear()
            }
            .withToolbarButtonStyle(showOver: showOverClearLog, activeState: controlActiveState)
            .popover(isPresented: $showOverClearLog, content: {
                renderHint(hint: Constants.toolbarClearLog)
            })
            .onHover(perform: { hovering in
                showOverClearLog = hovering && controlActiveState == .key
            })
            Button(Constants.toolbarSettings, systemImage: Constants.iconSettings) {
                showSettingsWindow()
            }
            .withToolbarButtonStyle(showOver: showOverSettings, activeState: controlActiveState)
            .popover(isPresented: $showOverSettings, content: {
                renderHint(hint: Constants.toolbarSettings)
            })
            .onHover(perform: { hovering in
                showOverSettings = hovering && controlActiveState == .key
            })
            Button(Constants.toolbarInfo, systemImage: Constants.iconInfo) {
                showInfoWindow()
            }
            .withToolbarButtonStyle(showOver: showOverInfo, activeState: controlActiveState)
            .popover(isPresented: $showOverInfo, content: {
                renderHint(hint: Constants.toolbarInfo)
            })
            .onHover(perform: { hovering in
                showOverInfo = hovering && controlActiveState == .key
            })
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
        if (!appState.views.isSettingsViewShown){
            openWindow(id: Constants.windowIdSettings)
            AppHelper.activateView(viewId: Constants.windowIdSettings)
        }
        else {
            AppHelper.activateView(viewId: Constants.windowIdSettings)
        }
    }
    
    private func showInfoWindow() {
        if (!appState.views.isInfoViewShown){
            openWindow(id: Constants.windowIdInfo)
            AppHelper.activateView(viewId: Constants.windowIdInfo)
        }
        else {
            AppHelper.activateView(viewId: Constants.windowIdInfo)
        }
    }
}

private extension Button {
    func withToolbarButtonStyle(showOver: Bool, activeState: ControlActiveState) -> some View {
        self.buttonStyle(.plain)
            .foregroundColor(showOver && activeState == .key ? .blue : .gray)
            .bold(showOver)
            .focusEffectDisabled()
            .font(.system(size: 17))
            .opacity(getViewOpacity(state: activeState))
            .pointerOnHover()
    }
}

#Preview {
    ToolbarView().environmentObject(AppState())
}
