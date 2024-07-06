//
//  AppState.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import Foundation
import CoreLocation

class AppState : ObservableObject {
    @Published var log = [LogEntry]()
    
    @Published var current = Current()
    @Published var views = Views()
    @Published var monitoring = Monitoring() { didSet { setCurrentState() } }
    @Published var system = System() { didSet { setCurrentState() } }
    @Published var network = Network() { didSet { setCurrentState() } }
    @Published var userData = UserData() { didSet { setCurrentState() } }
    
    static let shared = AppState()
    
    private func setCurrentState() {
        current.safetyType = determineSafetyType()
        current.isCurrentIpAllowed = getCurrentAllowedIp() != nil
        current.highRisk = checkIfHighRisk()
        current.countyDetected = checkIfCountryDetected()
    }
}

extension AppState {
    struct Current {
        var safetyType = SafetyType.unknown
        var isCurrentIpAllowed = false
        var highRisk = false
        var countyDetected = false
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
        var isEnabled = false {
            didSet { writeSetting(newValue: isEnabled, key: Constants.settingsKeyIsMonitoringEnabled) }
        }
        
        init() {
            isEnabled = readSetting(key: Constants.settingsKeyIsMonitoringEnabled) ?? false
        }
    }
}

extension AppState {
    struct System {
        var locationServicesEnabled: Bool {
            get { return CLLocationManager.locationServicesEnabled() }
        }
        var processesToKill = [ProcessInfo]()
    }
}

extension AppState {
    struct Network {
        var status: NetworkStatusType = NetworkStatusType.unknown
        var interfaces: [NetworkInterface] = [NetworkInterface]()
        var previousIpInfo: IpInfoBase? = nil
        var currentIpInfo: IpInfoBase? = nil {
            willSet { previousIpInfo = currentIpInfo }
        }
    }
}

extension AppState {
    struct UserData : Settable {
        var ipApis = [IpApiInfo]() {
            didSet { writeSettingsArray(newValues: ipApis, key: Constants.settingsKeyApis) }
        }
        var allowedIps = [IpInfo]() {
            didSet { writeSettingsArray(newValues: allowedIps, key: Constants.settingsKeyAddresses) }
        }
        var appsToClose = [AppInfo]() {
            didSet { writeSettingsArray(newValues: appsToClose, key: Constants.settingsKeyAppsToClose) }
        }
        var useHigherProtection: Bool = false {
            didSet { writeSetting(newValue: useHigherProtection, key: Constants.settingsKeyHigherProtection) }
        }
        var intervalBetweenChecks: Double = Constants.defaultIntervalBetweenChecksInSeconds {
            didSet { writeSetting(newValue: intervalBetweenChecks, key: Constants.settingsKeyIntervalBetweenChecks) }
        }
        var pickyMode: Bool = false {
            didSet { writeSetting(newValue: pickyMode, key: Constants.settingsKeyHigherProtection) }
        }
        var appCloseConfirmation: Bool = false {
            didSet { writeSetting(newValue: appCloseConfirmation, key: Constants.settingsKeyConfirmationApplicationsClose) }
        }
        
        init() {
            useHigherProtection = readSetting(key: Constants.settingsKeyHigherProtection) ?? false
            intervalBetweenChecks = readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? Constants.defaultIntervalBetweenChecksInSeconds
            pickyMode = readSetting(key: Constants.settingsKeyUsePickyMode) ?? false
            appCloseConfirmation = readSetting(key: Constants.settingsKeyConfirmationApplicationsClose) ?? true
            
            let savedAllowedIps: [IpInfo]? = readSettingsArray(key: Constants.settingsKeyAddresses)
            let savedIpApis: [IpApiInfo]? = readSettingsArray(key: Constants.settingsKeyApis)
            let savedAppsToClose: [AppInfo]? = readSettingsArray(key: Constants.settingsKeyAppsToClose)
            
            if (savedAllowedIps != nil) {
                allowedIps = savedAllowedIps!
            }
            
            if (savedIpApis == nil) {
                for ipApiUrl in Constants.ipApiUrls {
                    let apiInfo = IpApiInfo(url: ipApiUrl, active: true)
                    ipApis.append(apiInfo)
                }
            }
            else {
                ipApis = savedIpApis!
            }
            
            if (savedAppsToClose != nil) {
                appsToClose = savedAppsToClose!
            }
        }
    }
}

extension AppState {
    private func determineSafetyType() -> SafetyType {
        if (monitoring.isEnabled) {
            let currentAllowedIp = getCurrentAllowedIp()
            
            if(currentAllowedIp != nil && !system.locationServicesEnabled) {
                return currentAllowedIp!.safetyType
            }
            
            return SafetyType.unsafe
        }
        
        return SafetyType.unknown
    }
    
    private func getCurrentAllowedIp() -> IpInfo? {
        var result: IpInfo? = nil
        
        for allowedIp in userData.allowedIps {
            if (network.currentIpInfo?.ipAddress == allowedIp.ipAddress) {
                result = allowedIp
            }
        }
        
        return result
    }
    
    private func checkIfHighRisk() -> Bool {
        return monitoring.isEnabled && system.locationServicesEnabled
    }
    
    private func checkIfCountryDetected() -> Bool {
        return network.currentIpInfo != nil && !network.currentIpInfo!.countryName.isEmpty
    }

}
