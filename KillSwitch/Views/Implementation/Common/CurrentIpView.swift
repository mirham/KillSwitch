//
//  CurrentIpView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Factory

struct CurrentIpView: IpAddressContainerView {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Injected(\.ipService) private var ipService
    
    var body: some View {
        Section() {
            VStack{
                Text(Constants.currentIp.uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text(appState.network.publicIp?.ipAddress.uppercased() ?? Constants.none.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(getIpColor())
                    .contextMenu {
                        if(appState.network.publicIp?.ipAddress != nil){
                            Button(action: { AppHelper.copyTextToClipboard(text: appState.network.publicIp!.ipAddress)}) {
                                Text(Constants.menuItemCopy)
                            }
                            if (appState.current.safetyType == .unknown) {
                                Button(action: { addAllowedIp(safetyType: SafetyType.compete)}) {
                                    Text(Constants.menuItemAddAsAllowedIpWithCompletePrivacy)
                                }
                                Button(action: { addAllowedIp(safetyType: SafetyType.some)}) {
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
                    .isHidden(hidden: !appState.current.isHighRisk, remove: true)
                HStack {
                    let flag = getCountryFlag(countryCode: appState.network.publicIp?.countryCode ?? String())
                    Image(nsImage: flag)
                        .resizable()
                        .frame(width: flag.size.width, height: flag.size.height)
                    Text(appState.network.publicIp?.countryName.uppercased() ?? String())
                        .font(.system(size: 12))
                        .bold()
                }
                .opacity(0.7)
                .isHidden(hidden: !appState.current.isCountryDetected, remove: true)
            }
        }
    }
    
    // MARK: Private functions
    
    private func getIpColor() -> Color {
        return appState.monitoring.isEnabled
            ? getSafetyColor(safetyType: appState.current.safetyType, colorScheme: colorScheme)
            : .primary
    }
    
    private func addAllowedIp(safetyType : SafetyType) {
        ipService.addAllowedPublicIp(
            ip: appState.network.publicIp!.ipAddress,
            ipInfo: appState.network.publicIp,
            safetyType: safetyType)
    }    
}

#Preview {
    CurrentIpView().environmentObject(AppState())
}
