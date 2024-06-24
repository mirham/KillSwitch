//
//  MonitoringStateView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import FlagKit

struct CurrentIpView: View {
    @EnvironmentObject var networkStatusService : NetworkStatusService
    @EnvironmentObject var monitoringService : MonitoringService
    
    var appManagementService = AppManagementService.shared
    
    var body: some View {
        Section() {
            VStack{
                Text("Current IP".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text(networkStatusService.currentIpAddressInfo?.ipAddress.uppercased() ?? Constants.none.uppercased())
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(getCurrentSafetyColor())
                    .contextMenu {
                        if(networkStatusService.currentIpAddressInfo?.ipAddress != nil){
                            Button(action: {
                                appManagementService.copyTextToClipboard(text: networkStatusService.currentIpAddressInfo!.ipAddress)
                            }){
                                Text("Copy")
                            }
                            if (monitoringService.currentSafetyType == .unknown) {
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
                    Text(networkStatusService.currentIpAddressInfo?.countryName.uppercased() ?? String())
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
        
        let result = networkStatusService.currentIpAddressInfo?.ipAddress != nil
                        && monitoringService.currentSafetyType != .unknown
            ? monitoringService.locationServicesEnabled
                ? String(AddressSafetyType.unsafe.description)
                : String(format: mask, monitoringService.currentSafetyType.description)
            : String()
        
        return result
    }
    
    private func getCurrentSafetyColor() -> Color {
        var result = Color.primary
        
        guard networkStatusService.currentIpAddressInfo?.ipAddress != nil else { return result }
        
        if (isHighRisk()) {
            result = Color.red
            
            return result
        }
        
        result = monitoringService.currentSafetyType == AddressSafetyType.compete
            ? .green
            : monitoringService.currentSafetyType == AddressSafetyType.some
                ? .yellow
                : .primary
        
        return result
    }
    
    private func getIpCountryFlag() -> NSImage{
        var result = NSImage()
        
        if(networkStatusService.currentIpAddressInfo?.countryCode != nil
           && !networkStatusService.currentIpAddressInfo!.countryCode.isEmpty){
            result = Flag(countryCode: networkStatusService.currentIpAddressInfo!.countryCode)?.originalImage ?? NSImage()
        }
        
        return result
    }
    
    private func addAllowedIpAddress(safetyType : AddressSafetyType){
        monitoringService.addAllowedIpAddress(
            ipAddress: networkStatusService.currentIpAddressInfo!.ipAddress,
            ipAddressInfo: networkStatusService.currentIpAddressInfo,
            safetyType: safetyType)
    }
    
    private func isCountryDetected() -> Bool {
        let result = networkStatusService.currentIpAddressInfo != nil
         && !networkStatusService.currentIpAddressInfo!.countryName.isEmpty
        
        return result
    }
    
    private func isHighRisk() -> Bool {
        let result = monitoringService.isMonitoringEnabled && monitoringService.locationServicesEnabled
        
        return result
    }
    
    private func writeSettings() {
        appManagementService.writeSettingsArray(
            allObjects: monitoringService.allowedIpAddresses,
            key: Constants.settingsKeyAddresses)
    }
}

#Preview {
    CurrentIpView()
}
