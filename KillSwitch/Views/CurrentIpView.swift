//
//  CurrentIpView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI

struct CurrentIpView: IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    var ipService = IpService.shared
    
    var body: some View {
        Section() {
            VStack{
                Text(Constants.currentIp.uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text(appState.network.currentIpInfo?.ipAddress.uppercased() ?? Constants.none.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(getIpAddressColor())
                    .contextMenu {
                        if(appState.network.currentIpInfo?.ipAddress != nil){
                            Button(action: { AppHelper.copyTextToClipboard(text: appState.network.currentIpInfo!.ipAddress)}) {
                                Text(Constants.menuItemCopy)
                            }
                            if (appState.current.safetyType == .unknown) {
                                Button(action: { addAllowedIpAddress(safetyType: SafetyType.compete)}) {
                                    Text(Constants.menuItemAddAsAllowedIpWithCompletePrivacy)
                                }
                                Button(action: { addAllowedIpAddress(safetyType: SafetyType.some)}) {
                                    Text(Constants.menuItemAddAsAllowedIpWithSomePrivacy)
                                }
                            }
                        }
                    }
                Spacer().frame(height: 1)
                Text(appState.current.safetyType.fullDesctiption)
                    .textCase(.uppercase)
                    .font(.system(size: 10))
                    .bold()
                    .foregroundStyle(getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme))
                    .isHidden(hidden: appState.current.safetyType == .unknown, remove: true)
                Text(Constants.disableLocationServices)
                    .textCase(.lowercase)
                    .font(.system(size: 9))
                    .bold()
                    .foregroundStyle(getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme))
                    .isHidden(hidden: !appState.current.highRisk, remove: true)
                HStack {
                    let flag = getCountryFlag(countryCode: appState.network.currentIpInfo?.countryCode ?? String())
                    Image(nsImage: flag)
                        .resizable()
                        .frame(width: flag.size.width, height: flag.size.height)
                    Text(appState.network.currentIpInfo?.countryName.uppercased() ?? String())
                        .font(.system(size: 12))
                        .bold()
                }
                .opacity(0.7)
                .isHidden(hidden: !appState.current.countyDetected, remove: true)
            }
        }
    }
    
    // MARK: Private functions
    
    private func getIpAddressColor() -> Color {
        return appState.monitoring.isEnabled
            ? getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme)
            : .primary
    }
    
    private func addAllowedIpAddress(safetyType : SafetyType) {
        ipService.addAllowedIp(
            ip: appState.network.currentIpInfo!.ipAddress,
            ipInfo: appState.network.currentIpInfo,
            safetyType: safetyType)
    }    
}

#Preview {
    CurrentIpView().environmentObject(AppState())
}
