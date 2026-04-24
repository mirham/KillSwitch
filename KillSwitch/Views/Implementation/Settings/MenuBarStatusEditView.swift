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
    
    @State private var shownItems: [MenuBarElement] = []
    @State private var hiddenItems: [MenuBarElement] = []
    @State private var draggedItem: MenuBarElement?
    @State private var separatorInsertedDuringDrag = false
    
    var body: some View {
        VStack(alignment: .leading) {
            infoHeader
            Spacer()
                .frame(height: 15)
            itemsConfigurationView
            Spacer()
                .frame(height: 30)
            Toggle(Constants.settingsElementThemeColor, isOn: $appState.userData.menuBarUseThemeColor)
                .withSettingToggleStyle()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .onAppear(perform: fillMenuBarElementItems)
        .onChange(of: appState.monitoring, fillMenuBarElementItems)
        .onChange(of: appState.network, fillMenuBarElementItems)
        .onChange(of: appState.userData, fillMenuBarElementItems)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var infoHeader: some View {
        HStack {
            Image(systemName: Constants.iconInfoFill)
                .asInfoIcon()
            Text(Constants.hintMenuBarAdjustment)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var itemsConfigurationView: some View {
        VStack(alignment: .center) {
            Text(Constants.settingsElementShownItems)
                .asCenteredTitle()
            itemsRow(
                items: shownItems,
                sourceItems: $shownItems,
                destinationItems: $hiddenItems,
                keepLastItem: false
            )
            Text(Constants.settingsElementAvailableItems)
                .asCenteredTitle()
            itemsRow(
                items: hiddenItems,
                sourceItems: $hiddenItems,
                destinationItems: $shownItems,
                keepLastItem: true
            )
        }
        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .center)
    }
    
    @ViewBuilder
    private func itemsRow(
        items: [MenuBarElement],
        sourceItems: Binding<[MenuBarElement]>,
        destinationItems: Binding<[MenuBarElement]>,
        keepLastItem: Bool
    ) -> some View {
        LazyHStack(spacing: 5) {
            ForEach(items, id: \.id) { item in
                item
                    .onDrag {
                        draggedItem = item
                        separatorInsertedDuringDrag = false
                        return NSItemProvider(object: item.image)
                    }
                    .onDrop(
                        of: [.image],
                        delegate: DropViewDelegate(
                            draggedItem: $draggedItem,
                            sourceItems: sourceItems,
                            destinationItems: destinationItems,
                            separatorInsertedDuringDrag: $separatorInsertedDuringDrag,
                            item: item,
                            keepLastItem: keepLastItem
                        )
                    )
            }
        }
        .asMenuBarPreview()
        .onChange(of: shownItems) { _, _ in saveMenuBarElementItems() }
        .onChange(of: hiddenItems) { _, _ in saveMenuBarElementItems() }
    }
    
    // MARK: Private functions
    
    private func fillMenuBarElementItems() {
        shownItems = getMenuBarElements(
            keys: appState.userData.menuBarShownItems,
            appState: appState,
            colorScheme: colorScheme,
            exampleAllowed: true
        )
        
        hiddenItems = getMenuBarElements(
            keys: appState.userData.menuBarHiddenItems,
            appState: appState,
            colorScheme: colorScheme,
            exampleAllowed: true
        )
    }
    
    private func saveMenuBarElementItems() {
        appState.userData.menuBarShownItems = shownItems.map { $0.key }
        appState.userData.menuBarHiddenItems = hiddenItems.map { $0.key }
    }
}

private extension LazyHStack {
    func asMenuBarPreview() -> some View {
        self.frame(width: 420, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(.blue, lineWidth: 1))
    }
}

private extension Text {
    func asCenteredTitle() -> some View {
        self.font(.title3)
            .padding(.top)
            .padding(.bottom, 5)
    }
}

private extension Toggle {
    func withSettingToggleStyle() -> some View {
        self.toggleStyle(CheckToggleStyle())
            .pointerOnHover()
            .padding(.leading)
            .padding(.top)
    }
}

#Preview {
    MenuBarStatusEditView().environmentObject(AppState())
}
