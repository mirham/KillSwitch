//
//  MenuBarStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation
import SwiftUI

struct MenuBarStatusView : MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack{
            Image(renderMenuBarStatus(), scale: 1, label: Text(String()))
        }
    }
    
    // MARK: Private functions
    
    @MainActor
    private func renderMenuBarStatus() -> CGImage{
        let renderer = ImageRenderer(content: MenuBarStatusRawView(appState: appState, colorScheme: colorScheme))
        let result = renderer.cgImage
        
        return result!
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
        let shownItems = getMenuBarElements(
            keys: appState.userData.menuBarShownItems,
            appState: appState,
            colorScheme: colorScheme)
        
        HStack(spacing: 5) {
            ForEach(shownItems, id: \.id) { item in
                Image(nsImage: item.image)
            }
        }
    }
}

#Preview {
    MenuBarStatusView().environmentObject(AppState())
}
