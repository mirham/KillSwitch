//
//  ToggleNetworkView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import SwiftUI

struct ToggleNetworkView: View {
    @EnvironmentObject var networkStatusService : NetworkStatusService
    
    let networkManagementService = NetworkManagementService.shared

    var body: some View {
        Section {
            Toggle("Network", isOn: Binding(
                get: { networkStatusService.currentStatus == .on },
                set: {
                    if($0){
                        networkManagementService.enableNetworkInterface(interfaceName: "en0")
                    }
                    else{
                        networkManagementService.disableNetworkInterface(interfaceName: "en0")
                    }
                }
            ))
            .toggleStyle(CheckToggleStyle())
        }
        .font(.system(size: 18))
    }
}

#Preview {
    ToggleNetworkView()
}
