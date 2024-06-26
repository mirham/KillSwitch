//
//  NetworkStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import SwiftUI

struct NetworkStatusView : View {
    @EnvironmentObject var networkStatusService : NetworkStatusService
    
    private let networkManagementService = NetworkManagementService.shared
    
    @State private var showOverText = false

    var body: some View {
        Section {
            VStack {
                Text("Network".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                switch networkStatusService.currentStatus {
                    case .on:
                        Text("On".uppercased())
                            .frame(width: 60, height: 60)
                            .background(.green)
                            .foregroundColor(.black.opacity(0.5))
                            .font(.system(size: 18))
                            .bold()
                            .clipShape(Circle())
                            .onTapGesture(perform: { toggleNetwork(enable: false) })
                            .pointerOnHover()
                            .onHover(perform: { hovering in
                                showOverText = hovering
                            })
                            .popover(isPresented: $showOverText, content: {
                                Text("Click to disable network")
                                    .padding()
                                    .interactiveDismissDisabled()
                            })
                    case .off:
                        Text("Off".uppercased())
                            .frame(width: 60, height: 60)
                            .background(.red)
                            .foregroundColor(.black.opacity(0.5))
                            .font(.system(size: 18))
                            .bold()
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .onTapGesture(perform: { toggleNetwork(enable: true) })
                            .pointerOnHover()
                            .onHover(perform: { hovering in
                                showOverText = hovering
                            })
                            .popover(isPresented: $showOverText, content: {
                                Text("Click to enable network")
                                    .padding()
                                    .interactiveDismissDisabled()
                            })
                    case .wait:
                        Text("Wait".uppercased())
                            .frame(width: 60, height: 60)
                            .background(.yellow)
                            .foregroundColor(.black.opacity(0.5))
                            .font(.system(size: 18))
                            .bold()
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    case .unknown:
                        Text("N/A".uppercased())
                            .frame(width: 60, height: 60)
                            .background(.gray)
                            .foregroundColor(.black.opacity(0.5))
                            .font(.system(size: 18))
                            .bold()
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func toggleNetwork(enable : Bool) {
        showOverText = false
        
        if (enable) {
            networkManagementService.enableNetworkInterface(interfaceName: Constants.primaryNetworkInterfaceName)
        }
        else {
            networkManagementService.disableNetworkInterface(interfaceName: Constants.primaryNetworkInterfaceName)
        }
    }
    
}

#Preview {
    NetworkStatusView()
}
