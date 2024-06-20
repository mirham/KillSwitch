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
    @EnvironmentObject var monitoringService : MonitoringService
    
    var appManagementService = AppManagementService.shared
    
    var body: some View {
        Section() {
            VStack{
                Text("Current IP".uppercased())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.top)
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
                Spacer()
                    .frame(height: 5)
                HStack{
                    Image(nsImage: getIpCountryFlag())
                    Text(networkStatusService.currentIpAddressInfo?.countryName.uppercased() ?? String())
                        .foregroundStyle(.gray)
                        .font(.system(size: 12))
                        .bold()
                }
                Text(getCurrentSafetyTypeText())
                    .textCase(.uppercase)
                    .font(.system(size: 10))
                    .bold()
                    .foregroundStyle(getCurrentSafetyColor())
            }
            .onDisappear(){
                writeSettings()
            }
        }
    }
    
    private func getCurrentSafetyTypeText() -> String {
        let mask = "%1$@ safety"
        
        let result = networkStatusService.currentIpAddressInfo?.ipAddress != nil
                        && monitoringService.currentSafetyType != .unknown
                        ? String(format: mask, monitoringService.currentSafetyType.description)
                        : String()
        
        return result
    }
    
    private func getCurrentSafetyColor() -> Color {
        let result = networkStatusService.currentIpAddressInfo?.ipAddress != nil
                && monitoringService.currentSafetyType == AddressSafetyType.compete
                    ? Color.green
                    : networkStatusService.currentIpAddressInfo?.ipAddress != nil
                        && monitoringService.currentSafetyType == AddressSafetyType.some
                        ? Color.yellow
                        : Color.primary
        
        return result
    }
    
    private func getIpCountryFlag() -> NSImage{
        var result = NSImage()
        
        if(networkStatusService.currentIpAddressInfo?.countryCode != nil){
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
    
    private func writeSettings() {
        appManagementService.writeSettingsArray(
            allObjects: monitoringService.allowedIpAddresses,
            key: Constants.settingsKeyAddresses)
    }
}

#Preview {
    CurrentIpView()
}
