//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import Foundation
import SwiftUI
import FlagKit

struct CurrentIpView: View {
    @EnvironmentObject var networkStatusService : NetworkStatusService
    
    private let monitoringService = MonitoringService.shared
    
    var body: some View {
        Section() {
            VStack{
                Text("Current IP".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                Text(networkStatusService.currentIpAddress.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.blue)
                Spacer()
                    .frame(height: 5)
                HStack{
                    Image(nsImage: Flag(countryCode: networkStatusService.currentIpAddressCountryCode)?.originalImage ?? NSImage())
                    Text(networkStatusService.currentIpAddressCountryName.uppercased())
                        .foregroundStyle(.gray)
                        .font(.system(size: 12))
                        .bold()
                }
            }
        }
    }
}

#Preview {
    CurrentIpView()
}
