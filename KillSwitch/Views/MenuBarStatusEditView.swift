//
//  MenuBarStatusEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.07.2024.
//

import SwiftUI

struct MenuBarStatusEditView: MenuBarItemsContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var shownItems = [MenuBarElement]()
    @State private var hiddenItems = [MenuBarElement]()
    @State private var draggedItem: MenuBarElement?
    
    var body: some View {
        VStack {
            Text(Constants.settingsElementShownItems)
                .asCenteredTitle()
            
            LazyHStack(spacing: 5) {
                ForEach(shownItems, id: \.id) { item in
                    item
                        .onDrag({
                            self.draggedItem = item
                            return NSItemProvider(object: item.image)
                        })
                        .onDrop(of: [.image], delegate: DropViewDelegate(
                            draggedItem: $draggedItem,
                            sourceItems: $shownItems,
                            destinationItems: $hiddenItems,
                            item: item,
                            keepLastItem: false))
                }
            }
            .asMenuBarPreview()
            .onChange(of: shownItems, saveMenuBarElementItems)
            Text(Constants.settingsElementHiddenItems)
                .asCenteredTitle()
            LazyHStack(spacing: 5) {
                ForEach(hiddenItems, id: \.id) { item in
                    item
                        .onDrag({
                            self.draggedItem = item
                            return NSItemProvider(object: item.image)
                        })
                        .onDrop(of: [.image], delegate: DropViewDelegate(
                            draggedItem: $draggedItem,
                            sourceItems: $hiddenItems,
                            destinationItems: $shownItems,
                            item: item, 
                            keepLastItem: true))
                }
            }
            .asMenuBarPreview()
            .onChange(of: hiddenItems, saveMenuBarElementItems)
            Spacer()
        }
        .onAppear() {
            fillMenuBarElementItems()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: Private functions
    
    private func fillMenuBarElementItems() {
        let shownItems = getMenuBarElements(
            keys: appState.userData.menuBarShownItems,
            appState: appState,
            colorScheme: colorScheme,
            exampleAllowed: true)
        
        let hiddenItems = getMenuBarElements(
            keys: appState.userData.menuBarHiddenItems,
            appState: appState,
            colorScheme: colorScheme,
            exampleAllowed: true)
        
        self.shownItems.removeAll()
        self.hiddenItems.removeAll()
        
        for shownItem in shownItems {
            self.shownItems.append(shownItem)
        }
        
        for hiddenItem in hiddenItems {
            self.hiddenItems.append(hiddenItem)
        }
    }
    
    private func saveMenuBarElementItems() {
        appState.userData.menuBarShownItems = self.shownItems.map { $0.key}
        appState.userData.menuBarHiddenItems = self.hiddenItems.map { $0.key}
    }
}

private extension LazyHStack {
    func asMenuBarPreview() -> some View {
        self.frame(width: 420, height: 30)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 6
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.blue, lineWidth: 1)
            )
    }
}

private extension Text {
    func asCenteredTitle() -> some View {
        self.font(.title3)
            .padding(.top)
    }
}

#Preview {
    MenuBarStatusEditView().environmentObject(AppState())
}
