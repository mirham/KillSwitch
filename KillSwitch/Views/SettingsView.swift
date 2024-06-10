//
//  SettingsView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    let appManagementService = AppManagementService.shared
    
    var body: some View {
        VStack{
            AllowedAddressesView
                .init()
                .navigationSplitViewColumnWidth(250)
        }.onAppear(perform: {
            appManagementService.setViewToTop(viewName: "settings-view")
        }).onDisappear(perform: {
            appManagementService.isSettingsViewShowed = false
        }).frame(maxWidth: 300, maxHeight: 500)
    }
}

#Preview {
    SettingsView()
}
