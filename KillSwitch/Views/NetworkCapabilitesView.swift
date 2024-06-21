//
//  NetworkStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct NetworkCapabilitesView: View {
    @EnvironmentObject var networkStatusService : NetworkStatusService
    
    var body: some View {
        Section() {
            Section() {
                Text("Network capabilities".uppercased())
                    .font(.caption2)
                VStack(spacing: 10) {
                    HStack {
                        Text("Supports DNS")
                        Spacer()
                        Text(String(networkStatusService.isSupportsDns))
                    }
                    HStack {
                        Text("Low data mode")
                        Spacer()
                        Text(String(networkStatusService.isLowDataMode))
                    }
                    HStack {
                        Text("Cellular or a Personal Hotspot")
                        Spacer()
                        Text(String(networkStatusService.isHotspot))
                    }
                    HStack {
                        Text("Route IPv4 traffic")
                        Spacer()
                        Text(String(networkStatusService.supportsIp4))
                    }
                    HStack {
                        Text("Route IPv6 traffic")
                        Spacer()
                        Text(String(networkStatusService.supportsIp6))
                    }
                    HStack {
                        Text("Description")
                        Spacer()
                        Text(String(networkStatusService.description))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 110, height: 70)
                    }
                }
                .font(.system(size: 11))
                .padding()
            }
        }
    }
}

#Preview {
    NetworkCapabilitesView()
}
