//
//  ActiveConnectionsView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct ActiveConnectionsView : View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Section {
            VStack(spacing: 12) {
                Text(Constants.activeConnections.uppercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                ForEach(appState.network.activeNetworkInterfaces.sorted(by: { $0.name < $1.name }), id: \.name) { interface in
                    ConnectionItem(interface: interface)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ActiveConnectionsView().environmentObject(AppState())
}
