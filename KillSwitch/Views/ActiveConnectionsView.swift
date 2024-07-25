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
        Section() {
            VStack(spacing: 10){
                Text(Constants.activeConnections.uppercased())
                    .font(.caption2)
                ForEach(appState.network.activeNetworkInterfaces.sorted(by: {$0.name < $1.name}), id: \.id) { activeNetworkInterface in
                    HStack {
                        Image(systemName: getConnectionIcon(networkInterfaceType: activeNetworkInterface.type))
                        Text("\(activeNetworkInterface.type)".uppercased())
                        Spacer()
                        Text("\(activeNetworkInterface.isPhysical ? Constants.physical : Constants.virtual)")
                            .foregroundStyle(.gray)
                        Spacer()
                        Text(activeNetworkInterface.name)
                            .foregroundStyle(.gray)
                    }
                    .font(Font.system(size: 11))
                }
            }.padding()
        }
    }
    
    // MARK: Private functions
    
    private func getConnectionIcon(networkInterfaceType: NetworkInterfaceType) -> String {
        switch networkInterfaceType {
            case .cellular:
                return Constants.iconCellular
            case .loopback:
                return Constants.iconLoopback
            case .vpn:
                return Constants.iconVpn
            case .wifi:
                return Constants.iconWifi
            case .wired:
                return Constants.iconWired
            case .other, .unknown:
                return Constants.iconUnknownConnection
        }
    }
}

#Preview {
    ActiveConnectionsView().environmentObject(AppState())
}
