//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import FlagKit

struct CurrentIpView: View, Settable {
    @EnvironmentObject var appState: AppState
    
    var ipService = IpService.shared
    
    var body: some View {
        Section() {
            VStack{
                Text("Current IP".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text(appState.network.currentIpInfo?.ipAddress.uppercased() ?? Constants.none.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(getCurrentSafetyColor())
                    .contextMenu {
                        if(appState.network.currentIpInfo?.ipAddress != nil){
                            Button(action: {
                                AppHelper.copyTextToClipboard(text: appState.network.currentIpInfo!.ipAddress)
                            }){
                                Text("Copy")
                            }
                            if (appState.current.safetyType == .unknown) {
                                Button(action: {
                                    addAllowedIpAddress(safetyType: AddressSafetyType.compete)
                                }){
                                    Text("Add as allowed IP with complete privacy")
                                }
                                Button(action: {
                                    addAllowedIpAddress(safetyType: AddressSafetyType.some)
                                }){
                                    Text("Add as allowed IP with some privacy")
                                }
                            }
                        }
                    }
                Spacer().frame(height: 1)
                Text(getCurrentSafetyTypeText())
                    .textCase(.uppercase)
                    .font(.system(size: 10))
                    .bold()
                    .foregroundStyle(getCurrentSafetyColor())
                    .isHidden(hidden: getCurrentSafetyTypeText().isEmpty, remove: true)
                Text("(disable location services)")
                    .textCase(.lowercase)
                    .font(.system(size: 9))
                    .bold()
                    .foregroundStyle(getCurrentSafetyColor())
                    .isHidden(hidden: !isHighRisk(), remove: true)
                HStack {
                    Image(nsImage: getIpCountryFlag())
                        .resizable()
                        .frame(width: 20, height: 12)
                    Text(appState.network.currentIpInfo?.countryName.uppercased() ?? String())
                        .font(.system(size: 12))
                        .bold()
                }
                .opacity(0.7)
                .isHidden(hidden: !isCountryDetected(), remove: true)
            }
            .onDisappear(){
                writeSettings()
            }
        }
    }
    
    // MARK: Private functions
    
    private func getCurrentSafetyTypeText() -> String {
        let mask = "%1$@ safety"
        
        let result = appState.network.currentIpInfo?.ipAddress != nil
                        && appState.current.safetyType != .unknown
        ? appState.system.locationServicesEnabled
                ? String(AddressSafetyType.unsafe.description)
                : String(format: mask, appState.current.safetyType.description)
            : String()
        
        return result
    }
    
    private func getCurrentSafetyColor() -> Color {
        var result = Color.primary
        
        guard appState.network.currentIpInfo?.ipAddress != nil else { return result }
        
        if (isHighRisk()) {
            result = Color.red
            
            return result
        }
        
        result = appState.current.safetyType == AddressSafetyType.compete
            ? .green
            : appState.current.safetyType == AddressSafetyType.some
                ? .yellow
                : .primary
        
        return result
    }
    
    private func getIpCountryFlag() -> NSImage{
        var result = NSImage()
        
        if(appState.network.currentIpInfo?.countryCode != nil
           && !appState.network.currentIpInfo!.countryCode.isEmpty){
            result = Flag(countryCode: appState.network.currentIpInfo!.countryCode)?.originalImage ?? NSImage()
        }
        
        return result
    }
    
    private func addAllowedIpAddress(safetyType : AddressSafetyType){
        ipService.addAllowedIp(
            ip: appState.network.currentIpInfo!.ipAddress,
            ipInfo: appState.network.currentIpInfo,
            safetyType: safetyType)
    }
    
    private func isCountryDetected() -> Bool {
        let result = appState.network.currentIpInfo != nil
         && !appState.network.currentIpInfo!.countryName.isEmpty
        
        return result
    }
    
    private func isHighRisk() -> Bool {
        let result = appState.monitoring.isEnabled && appState.system.locationServicesEnabled
        
        return result
    }
    
    private func writeSettings() {
        writeSettingsArray(
            allObjects: appState.userData.allowedIps,
            key: Constants.settingsKeyAddresses)
    }
}

#Preview {
    CurrentIpView()
}
