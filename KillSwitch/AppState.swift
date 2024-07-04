//
//  AppState.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import Foundation

class AppState : ObservableObject {
    @Published var log = [LogEntry]()
    
    @Published var current = Current()
    @Published var views = Views()
    @Published var monitoring = Monitoring()
    @Published var system = System()
    @Published var network = Network()
    @Published var userData = UserData()
    
    static let shared = AppState()
}

extension AppState {
    struct Current {
        var safetyType = AddressSafetyType.unknown
    }
}

extension AppState {
    struct Views {
        var isMainViewShowed = false
        var isStatusBarViewShowed = false
        var isSettingsViewShowed = false
        var isKillProcessesConfirmationDialogShowed = false
    }
}

extension AppState {
    struct Monitoring : Settable {
        var isEnabled = false
        
        init() {
            isEnabled = readSetting(key: Constants.settingsKeyIsMonitoringEnabled) ?? false
        }
    }
}

extension AppState {
    struct System {
        var locationServicesEnabled = true
        var processesToClose = [ProcessInfo]()
    }
}

extension AppState {
    struct Network {
        var status: NetworkStatusType = NetworkStatusType.unknown
        var interfaces: [NetworkInterface] = [NetworkInterface]()
        var ipAddressInfo: AddressInfoBase? = nil
    }
}

extension AppState {
    struct UserData : Settable {
        var ipApis = [ApiInfo]()
        var allowedIps = [AddressInfo]()
        var appsToClose = [AppInfo]()
        
        init() {
            let savedAllowedIpAddresses: [AddressInfo]? = readSettingsArray(key: Constants.settingsKeyAddresses)
            
            if(savedAllowedIpAddresses != nil){
                allowedIps = savedAllowedIpAddresses!
            }
            
            let savedApis: [ApiInfo]? = readSettingsArray(key: Constants.settingsKeyApis)
            
            if(savedApis == nil){
                for addressApiUrl in Constants.addressApiUrls {
                    let apiInfo = ApiInfo(url: addressApiUrl, active: true)
                    ipApis.append(apiInfo)
                }
            }
            else{
                ipApis = savedApis!
            }
            
            let savedAppsToClose: [AppInfo]? = readSettingsArray(key: Constants.settingsKeyAppsToClose)
            
            if(savedAppsToClose != nil){
                appsToClose = savedAppsToClose!
            }
        }
    }
}
