//
//  NetworkStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct NetworkInterfacesView : View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Section() {
            VStack(spacing: 10){
                Text("Active connections".uppercased())
                    .font(.caption2)
                ForEach(appState.network.interfaces, id: \.id) { activeNetworkInterface in
                    HStack {
                        Text(activeNetworkInterface.name)
                        Spacer()
                        Text("\(activeNetworkInterface.type)")
                    }
                }
            }.padding()
        }
    }
}

#Preview {
    NetworkInterfacesView()
}
