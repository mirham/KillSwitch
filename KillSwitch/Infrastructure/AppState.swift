//
//  AppState.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import SwiftUI
import CoreLocation

class AppState : ObservableObject, Equatable {
    @Published var log = [LogEntry]()
    
    @Published var current = Current()
    @Published var views = Views(shownWindows: [String()])
    @Published var monitoring = Monitoring() { didSet { setCurrentState() } }
    @Published var system = System() { didSet { setCurrentState() } }
    @Published var network = Network() { didSet { setCurrentState() } }
    @Published var userData = UserData() { didSet { setCurrentState() } }
    
    static let shared = AppState()
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        let result = lhs.current == rhs.current
        && lhs.monitoring == rhs.monitoring
        && lhs.network == rhs.network
        
        return result
    }
    
    func applyMonitoringUpdate(_ update: MonitoringStateUpdate) {
        if let isMonitoringEnabled = update.isMonitoringEnabled {
            monitoring.isEnabled = isMonitoringEnabled
        }
        
        if let publicIp = update.publicIp {
            network.publicIp = publicIp
        }
    }
    
    func applyNetworkUpdate(_ update: NetworkStateUpdate) {
        var updatedNetwork = network
        
        if let status = update.status {
            updatedNetwork.status = status
            
            if network.status != .on && status == .on {
                reactivateIpApis()
            }
        }
        
        if update.forceUpdatePublicIp {
            updatedNetwork.publicIp = update.publicIp
        }
        
        if let activeInterfaces = update.activeNetworkInterfaces {
            updatedNetwork.activeNetworkInterfaces = activeInterfaces
        }
        
        if let physicalInterfaces = update.physicalNetworkInterfaces {
            updatedNetwork.physicalNetworkInterfaces = physicalInterfaces
        }
        
        if let isFetchingIp = update.isFetchingIp {
            updatedNetwork.isFetchingIp = isFetchingIp
        }
        
        if let hasDnsLeak = update.hasDnsLeak {
            updatedNetwork.hasDnsLeak = hasDnsLeak
        }
        
        if let hasWebRtcLeak = update.hasWebRtcLeak {
            updatedNetwork.hasWebRtcLeak = hasWebRtcLeak
        }
        
        if network != updatedNetwork {
            network = updatedNetwork
        }
    }
    
    func applyProcessesStateUpdate (_ update: ProcessesStateUpdate) {
        system.killingProcesses = update.killingProcesses ?? []
        system.monitoringProcesses = update.monitoringProcesses ?? []
    }
    
    // MARK: Private functions
    
    private func setCurrentState() {
        current.securityType = determineSecurityType()
        current.isPublicIpAllowed = getCurrentAllowedIp() != nil
        current.isHighRisk = isHighRisk()
        current.isCountryDetected = isCountryDetected()
        current.mainNetworkInterface = findMainInterface()
        current.isDnsLeakCheckEnabled = isDnsLeakCheckEnabled()
        current.isWebRtcLeakCheckEnabled = isWebRtcLeakCheckEnabled()
    }
}

extension AppState {
    struct Current : Equatable {
        var securityType = SecurityType.unknown
        var isPublicIpAllowed = false
        var isHighRisk = false
        var isCountryDetected = false
        var mainNetworkInterface = String()
        var colorScheme: ColorScheme = .light
        var isDnsLeakCheckEnabled = false
        var isWebRtcLeakCheckEnabled = false
        
        var areLeakChecksEnabled: Bool {
            get { isDnsLeakCheckEnabled || isWebRtcLeakCheckEnabled }
        }
        
        static func == (lhs: Current, rhs: Current) -> Bool {
            let result = lhs.securityType == rhs.securityType
            && lhs.isHighRisk == rhs.isHighRisk
            && lhs.isPublicIpAllowed == rhs.isPublicIpAllowed
            && lhs.isDnsLeakCheckEnabled == rhs.isDnsLeakCheckEnabled
            && lhs.isWebRtcLeakCheckEnabled == rhs.isWebRtcLeakCheckEnabled
            
            return result
        }
    }
}

extension AppState {
    struct Views {
        var shownWindows: [String]
    }
}

extension AppState {
    struct Monitoring : Settable, Equatable {
        var isEnabled = false {
            didSet { writeSetting(newValue: isEnabled, key: Constants.settingsKeyIsMonitoringEnabled) }
        }
        
        init() {
            isEnabled = readSetting(key: Constants.settingsKeyIsMonitoringEnabled) ?? false
        }
        
        static func == (lhs: Monitoring, rhs: Monitoring) -> Bool {
            let result = lhs.isEnabled == rhs.isEnabled
            
            return result
        }
    }
}

extension AppState {
    struct System {
        var locationServicesEnabled: Bool {
            get { return CLLocationManager.locationServicesEnabled() }
        }
        var killingProcesses: [ProcessInfo] = []
        var monitoringProcesses: [ProcessInfo] = []
    }
}

extension AppState {
    struct Network : Equatable {
        var status: NetworkStatusType = NetworkStatusType.unknown
        var isFetchingIp = false
        var activeNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
        var physicalNetworkInterfaces: [NetworkInterface] = [NetworkInterface]()
        var publicIp: IpInfoBase? = nil
        var hasDnsLeak: Bool = false
        var hasWebRtcLeak: Bool = false
        
        var hasLeak: Bool {
            get { hasDnsLeak || hasWebRtcLeak }
        }
        
        var firstPhysicalInterface: NetworkInterface? {
            get { physicalNetworkInterfaces.first }
        }
        
        var isVpnConnected: Bool {
            get { activeNetworkInterfaces.contains(where: {$0.type == .vpn}) }
        }
        
        func isConnectionChanged (
            status: NetworkStatusType,
            activeNetworkInterfaces: [NetworkInterface]) -> Bool {
                let result = self.status != status || self.activeNetworkInterfaces != activeNetworkInterfaces
                return result
            }
        
        static func == (lhs: Network, rhs: Network) -> Bool {
            let result = lhs.status == rhs.status
            && lhs.publicIp == rhs.publicIp
            && lhs.publicIp?.hasLocation() == rhs.publicIp?.hasLocation()
            && lhs.isFetchingIp == rhs.isFetchingIp
            && lhs.activeNetworkInterfaces == rhs.activeNetworkInterfaces
            && lhs.physicalNetworkInterfaces == rhs.physicalNetworkInterfaces
            && lhs.hasDnsLeak == rhs.hasDnsLeak
            && lhs.hasWebRtcLeak == rhs.hasWebRtcLeak
            
            return result
        }
    }
    
    // MARK: Private functions
    
    private func reactivateIpApis() {
        for index in 0..<userData.ipApis.count {
            if !userData.ipApis[index].isActive() {
                userData.ipApis[index].active = true
            }
        }
    }
}

extension AppState {
    struct UserData : Settable, Equatable {
        var ipApis = [IpApiInfo]() {
            didSet {
                writeSettingsArray(
                    newValues: ipApis,
                    key: Constants.settingsKeyApis
                )
            }
        }
        
        var ipApisRemoved = [IpApiInfo]() {
            didSet {
                writeSettingsArray(
                    newValues: ipApisRemoved,
                    key: Constants.settingsKeyApisRemoved
                )
            }
        }
        
        var allowedIps = [IpInfo]() {
            didSet {
                writeSettingsArray(
                    newValues: allowedIps,
                    key: Constants.settingsKeyIps
                )
            }
        }
        
        var appsToClose = [AppInfo]() {
            didSet {
                writeSettingsArray(
                    newValues: appsToClose,
                    key: Constants.settingsKeyAppsToClose
                )
            }
        }
        
        var useExtendedProtection: Bool = false {
            didSet {
                writeSetting(
                    newValue: useExtendedProtection,
                    key: Constants.settingsKeyExtendedProtection
                )
            }
        }
        
        var intervalBetweenChecks: Int = Constants.defaultIntervalBetweenChecksInSeconds {
            didSet {
                writeSetting(
                    newValue: intervalBetweenChecks,
                    key: Constants.settingsKeyIntervalBetweenChecks
                )
            }
        }
        
        var pickyMode: Bool = true {
            didSet {
                writeSetting(
                    newValue: pickyMode,
                    key: Constants.settingsKeyUsePickyMode
                )
            }
        }
        
        var periodicIpCheck: Bool = false {
            didSet {
                writeSetting(
                    newValue: periodicIpCheck,
                    key: Constants.settingsKeyPeriodicIpCheck
                )
            }
        }
        
        var autoCloseApps: Bool = false {
            didSet {
                writeSetting(
                    newValue: autoCloseApps,
                    key: Constants.settingsKeyAutoCloseApps
                )
            }
        }
        
        var appsCloseConfirmation: Bool = false {
            didSet {
                writeSetting(
                    newValue: appsCloseConfirmation,
                    key: Constants.settingsKeyConfirmationApplicationsClose
                )
            }
        }
        
        var menuBarShownItems = Constants.defaultShownMenuBarItems {
            didSet {
                writeSettingsArray(
                    newValues: menuBarShownItems,
                    key: Constants.settingsKeyShownMenuBarItems
                )
            }
        }
        
        var menuBarHiddenItems = Constants.defaultHiddenMenuBarItems {
            didSet {
                writeSettingsArray(
                    newValues: menuBarHiddenItems,
                    key: Constants.settingsKeyHiddenMenuBarItems)
            }
        }
        
        var menuBarUseThemeColor: Bool = false {
            didSet {
                writeSetting(
                    newValue: menuBarUseThemeColor,
                    key: Constants.settingsKeyMenuBarUseThemeColor
                )
            }
        }
        
        var onTopOfAllWindows: Bool = false {
            didSet {
                writeSetting(
                    newValue: onTopOfAllWindows,
                    key: Constants.settingsKeyOnTopOfAllWindows
                )
            }
        }
        
        var preventComputerSleep: Bool = false {
            didSet {
                writeSetting(
                    newValue: preventComputerSleep,
                    key: Constants.settingsKeyPreventComputerSleep
                )
            }
        }
        
        var dnsLeakCheck: Bool = true {
            didSet {
                writeSetting(
                    newValue: dnsLeakCheck,
                    key: Constants.settingsKeyDnsLeakCheck
                )
            }
        }
        
        var dnsLeakCheckInterval: Int = Constants.defaultDnsLeakCheckIntervalInSeconds {
            didSet {
                writeSetting(
                    newValue: dnsLeakCheckInterval,
                    key: Constants.settingsKeyDnsLeakCheckInterval
                )
            }
        }
        
        var webRtcLeakCheck: Bool = true {
            didSet {
                writeSetting(
                    newValue: webRtcLeakCheck,
                    key: Constants.settingsKeyWebRtcLeakCheck
                )
            }
        }
        
        var webRtcMonitoredApps = [MonitoredAppInfo]() {
            didSet {
                writeSettingsArray(
                    newValues: webRtcMonitoredApps,
                    key: Constants.settingsKeyWebRtcMonitoredApps
                )
            }
        }
        
        var webRtcLeakCheckInterval: Int = Constants.defaultWebRtcLeakCheckIntervalInSeconds {
            didSet {
                writeSetting(
                    newValue: webRtcLeakCheckInterval,
                    key: Constants.settingsKeyWebRtcLeakCheckInterval
                )
            }
        }
        
        var ipInfoApiUrl: String = Constants.defaultIpInfoApiUrl {
            didSet {
                writeSetting(
                    newValue: ipInfoApiUrl,
                    key: Constants.settingsKeyIpInfoApiUrl
                )
            }
        }
        
        var ipInfoApiKeyMapping: [String:String] = Constants.defaultIpInfoApiKeyMapping {
            didSet {
                writeSettingsDictionary(
                    newValues: ipInfoApiKeyMapping,
                    key: Constants.settingsKeyIpInfoMapping
                )
            }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
            
            return result
        }
        
        init() {
            useExtendedProtection = readSetting(key: Constants.settingsKeyExtendedProtection) ?? false
            intervalBetweenChecks = readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? Constants.defaultIntervalBetweenChecksInSeconds
            pickyMode = readSetting(key: Constants.settingsKeyUsePickyMode) ?? true
            periodicIpCheck = readSetting(key: Constants.settingsKeyPeriodicIpCheck) ?? true
            autoCloseApps = readSetting(key: Constants.settingsKeyAutoCloseApps) ?? false
            appsCloseConfirmation = readSetting(key: Constants.settingsKeyConfirmationApplicationsClose) ?? true
            onTopOfAllWindows = readSetting(key: Constants.settingsKeyOnTopOfAllWindows) ?? false
            preventComputerSleep = readSetting(key: Constants.settingsKeyPreventComputerSleep) ?? false
            dnsLeakCheck = readSetting(key: Constants.settingsKeyDnsLeakCheck) ?? true
            dnsLeakCheckInterval = readSetting(key: Constants.settingsKeyDnsLeakCheckInterval) ?? Constants.defaultDnsLeakCheckIntervalInSeconds
            webRtcLeakCheck = readSetting(key: Constants.settingsKeyWebRtcLeakCheck) ?? true
            webRtcLeakCheckInterval = readSetting(key: Constants.settingsKeyWebRtcLeakCheckInterval) ?? Constants.defaultWebRtcLeakCheckIntervalInSeconds
            menuBarUseThemeColor = readSetting(key: Constants.settingsKeyMenuBarUseThemeColor) ?? false
            
            if let savedAllowedIps: [IpInfo] = readSettingsArray(
                key: Constants.settingsKeyIps) {
                allowedIps = savedAllowedIps
            }
            
            let defaultIpApis = getDefaultIpApis()
            
            if let savedIpApisRemoved: [IpApiInfo] = readSettingsArray(
                key: Constants.settingsKeyApisRemoved) {
                ipApisRemoved = savedIpApisRemoved
            }
            
            if let savedIpApis: [IpApiInfo] = readSettingsArray(
                key: Constants.settingsKeyApis) {
                ipApis = savedIpApis.syncWithDefaults(
                    defaultIpApis,
                    excluding: ipApisRemoved)
            }
            else {
                ipApis = defaultIpApis
            }
            
            if let savedAppsToClose:[AppInfo] = readSettingsArray(
                key: Constants.settingsKeyAppsToClose) {
                appsToClose = savedAppsToClose
            }
            
            if let savedWebRtcMonitoredApps:[MonitoredAppInfo] = readSettingsArray(
                key: Constants.settingsKeyWebRtcMonitoredApps) {
                webRtcMonitoredApps = savedWebRtcMonitoredApps
            }
            else {
                webRtcMonitoredApps = Constants.webRtcMonitoredApps
            }
            
            if let savedMenuBarShownItems:[String] = readSettingsArray(
                key: Constants.settingsKeyShownMenuBarItems) {
                menuBarShownItems = savedMenuBarShownItems
            }
            
            if let savedMenuBarHiddenItems: [String] = readSettingsArray(
                key: Constants.settingsKeyHiddenMenuBarItems) {
                menuBarHiddenItems = savedMenuBarHiddenItems.syncWithDefaults(
                    Constants.defaultHiddenMenuBarItems,
                    excluding: menuBarShownItems.filter({!$0.isSeparator()})
                )
            }
        }
        
        func getRandomActiveIpApi() -> IpApiInfo? {
            let result = ipApis.filter({$0.isActive()}).randomElement()
            
            return result
        }
        
        func hasActiveIpApi() -> Bool {
            return !ipApis.isEmpty && ipApis.contains(where: {$0.isActive()})
        }
        
        func getDefaultIpApis() -> [IpApiInfo] {
            var result = [IpApiInfo]()
            
            for ipApiUrl in Constants.ipApiUrls {
                let apiInfo = IpApiInfo(url: ipApiUrl, active: true)
                result.append(apiInfo)
            }
            
            return result
        }
    }
}

extension AppState {
    private func determineSecurityType() -> SecurityType {
        guard monitoring.isEnabled
        else { return .unknown }
        
        guard network.publicIp != nil
        else { return .unknown }
        
        guard let currentAllowedIp = getCurrentAllowedIp(),
              !system.locationServicesEnabled,
              !network.hasDnsLeak,
              !network.hasWebRtcLeak
        else { return .notSecure }
        
        return currentAllowedIp.securityType
    }
    
    private func getCurrentAllowedIp() -> IpInfo? {
        guard let publicIp = network.publicIp?.ipAddress
        else { return nil }
        
        return userData.allowedIps.first { $0.ipAddress == publicIp }
    }
    
    private func isHighRisk() -> Bool {
        return monitoring.isEnabled
            && (system.locationServicesEnabled
                || network.hasDnsLeak
                || network.hasWebRtcLeak)
    }
    
    private func isCountryDetected() -> Bool {
        return network.publicIp != nil && !network.publicIp!.countryName.isEmpty
    }
    
    private func findMainInterface() -> String {
        for activeInterface in network.activeNetworkInterfaces {
            for physicalInterface in network.physicalNetworkInterfaces {
                if (activeInterface.name == physicalInterface.name) {
                    return activeInterface.name
                }
            }
        }
        
        return current.mainNetworkInterface
    }
    
    private func isDnsLeakCheckEnabled() -> Bool {
        return monitoring.isEnabled
            && userData.dnsLeakCheck
            && network.status == .on
            && network.isVpnConnected
    }
    
    private func isWebRtcLeakCheckEnabled() -> Bool {
        return monitoring.isEnabled
            && userData.webRtcLeakCheck
            && network.status == .on
            && network.isVpnConnected
    }
}
