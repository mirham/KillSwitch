//
//  MenuBarStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import SwiftUI

struct MenuBarStatusView : MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @MainActor
    var body: some View {
        HStack{
            let image = MenuBarStatusRawView(
                appState: appState,
                colorScheme: colorScheme).renderAsImage()
            Image(nsImage: image!)
                .nonAntialiased()
                .scaledToFit()
        }
        .onAppear(){
            appState.current.colorScheme = colorScheme
        }
        .onChange(of: colorScheme) {
            appState.current.colorScheme = colorScheme
        }
    }
}

// MARK: Inner types

private struct MenuBarStatusRawView: MenuBarItemsContainerView {
    private let appState: AppState
    private let colorScheme: ColorScheme
    
    init(appState: AppState, colorScheme: ColorScheme) {
        self.appState = appState
        self.colorScheme = colorScheme
    }
    
    var body: some View {
        if !appState.userData.hasActiveIpApi() {
            makeNoActiveIpApiView()
        }
        else {
            makeDefaultView(appState: appState, colorScheme: colorScheme)
        }
    }
    
    // MARK: Private functions
    
    private func makeNoActiveIpApiView() -> some View {
        HStack {
            Image(systemName: Constants.iconNoActiveIpApi)
            Text(Constants.noActiveIpApi.uppercased())
        }
        .foregroundStyle(.orange)
    }
    
    @MainActor
    private func makeDefaultView(
        appState: AppState,
        colorScheme: ColorScheme) -> some View {
            let shownItems = getMenuBarElements(
                keys: appState.userData.menuBarShownItems,
                appState: appState,
                colorScheme: colorScheme)
            
            return HStack(spacing: 5) {
                ForEach(shownItems, id: \.id) { item in
                    Image(nsImage: item.image)
                        .nonAntialiased()
                }
            }
        }
}

#Preview {
    MenuBarStatusView().environmentObject(AppState())
}
