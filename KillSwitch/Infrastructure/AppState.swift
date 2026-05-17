//
//  AppState.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import SwiftUI
import CoreLocation

@MainActor
class AppState: ObservableObject {
    @Published var log = [LogEntry]()
    
    @Published var current = Current()
    @Published var monitoring = Monitoring() { didSet { setCurrentState() } }
    @Published var system = System() { didSet { setCurrentState() } }
    @Published var network = Network() { didSet { setCurrentState() } }
    @Published var userData = UserData() { didSet { setCurrentState() } }
    
    static let shared = AppState()
    
    func applyMonitoringUpdate(_ update: MonitoringStateUpdate) {
        var updatedMonitoring = monitoring
        var updatedNetwork = network
        
        if let isMonitoringEnabled = update.isMonitoringEnabled {
            updatedMonitoring.isEnabled = isMonitoringEnabled
        }
        if let publicIp = update.publicIp {
            updatedNetwork.publicIp = publicIp
        }
        
        monitoring = updatedMonitoring
        network = updatedNetwork
    }
    
    func applyNetworkUpdate(_ update: NetworkStateUpdate) {
        var updatedNetwork = network
        var shouldReactivateIpApis = false
        
        if let status = update.status {
            if network.status != .on && status == .on {
                shouldReactivateIpApis = true
            }
            
            updatedNetwork.status = status
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
        
        if shouldReactivateIpApis {
            reactivateIpApis()
        }
    }
    
    func applyProcessesStateUpdate(_ update: ProcessesStateUpdate) {
        var updatedSystem = system
        
        updatedSystem.closingProcesses = update.closingProcesses ?? []
        updatedSystem.webRtcMonitoredProcesses = update.webRtcMonitoredProcesses ?? []
        

        if system.closingProcesses != updatedSystem.closingProcesses
            || system.webRtcMonitoredProcesses != updatedSystem.webRtcMonitoredProcesses {
            system = updatedSystem
        }
    }
    
    // MARK: Private
    
    private func setCurrentState() {
        var updated = current
        updated.securityType = determineSecurityType()
        updated.isPublicIpAllowed = getCurrentAllowedIp() != nil
        updated.isHighRisk = isHighRisk()
        updated.isCountryDetected = isCountryDetected()
        updated.mainNetworkInterface = findMainInterface()
        updated.isDnsLeakCheckEnabled = isDnsLeakCheckEnabled()
        updated.isWebRtcLeakCheckEnabled = isWebRtcLeakCheckEnabled()
        
        if current != updated {
            current = updated
        }
    }
}

extension AppState {
    struct Current: Equatable {
        var securityType = SecurityType.unknown
        var isPublicIpAllowed = false
        var isHighRisk = false
        var isCountryDetected = false
        var mainNetworkInterface = String()
        var colorScheme: ColorScheme = .light
        var isDnsLeakCheckEnabled = false
        var isWebRtcLeakCheckEnabled = false
        
        var areLeakChecksEnabled: Bool {
            isDnsLeakCheckEnabled || isWebRtcLeakCheckEnabled
        }
        
        static func == (lhs: Current, rhs: Current) -> Bool {
            lhs.securityType == rhs.securityType
            && lhs.isHighRisk == rhs.isHighRisk
            && lhs.isPublicIpAllowed == rhs.isPublicIpAllowed
            && lhs.isDnsLeakCheckEnabled == rhs.isDnsLeakCheckEnabled
            && lhs.isWebRtcLeakCheckEnabled == rhs.isWebRtcLeakCheckEnabled
        }
    }
}

extension AppState {
    struct Monitoring: Settable, Equatable {
        var isEnabled = false {
            didSet { writeSetting(newValue: isEnabled, key: Constants.settingsKeyIsMonitoringEnabled) }
        }
        
        init() {
            isEnabled = readSetting(key: Constants.settingsKeyIsMonitoringEnabled)
                ?? false
        }
        
        static func == (lhs: Monitoring, rhs: Monitoring) -> Bool {
            lhs.isEnabled == rhs.isEnabled
        }
    }
}

extension AppState {
    struct System: Equatable {
        var locationServicesEnabled: Bool {
            CLLocationManager.locationServicesEnabled()
        }
        var closingProcesses: [ProcessInfo] = []
        var webRtcMonitoredProcesses: [ProcessInfo] = []
        
        static func == (lhs: System, rhs: System) -> Bool {
            lhs.closingProcesses == rhs.closingProcesses
            && lhs.webRtcMonitoredProcesses == rhs.webRtcMonitoredProcesses
        }
    }
}

extension AppState {
    struct Network: Equatable {
        var status: NetworkStatusType = .unknown
        var isFetchingIp = false
        var activeNetworkInterfaces: [NetworkInterface] = []
        var physicalNetworkInterfaces: [NetworkInterface] = []
        var publicIp: IpInfoBase? = nil
        var hasDnsLeak = false
        var hasWebRtcLeak = false
        
        var hasLeak: Bool { hasDnsLeak || hasWebRtcLeak }
        
        var firstPhysicalInterface: NetworkInterface? {
            physicalNetworkInterfaces
                .first(where: { $0.type != .other })
            ?? physicalNetworkInterfaces.first
        }
        
        var isVpnConnected: Bool {
            activeNetworkInterfaces.contains(where: { $0.type == .vpn })
        }
        
        var currentPhysicalInterfaceIcon: String {
            firstPhysicalInterface?.type.icon
            ?? activeNetworkInterfaces
                .first(where: { $0.isPhysical && $0.type != .other })?.type.icon
            ?? activeNetworkInterfaces
                .first(where: { $0.isPhysical })?.type.icon
            ?? NetworkInterfaceType.unknown.icon
        }
        
        func isConnectionChanged(
            status: NetworkStatusType,
            activeNetworkInterfaces: [NetworkInterface]) -> Bool {
            self.status != status
                || self.activeNetworkInterfaces != activeNetworkInterfaces
        }
        
        static func == (lhs: Network, rhs: Network) -> Bool {
            lhs.status == rhs.status
            && lhs.publicIp == rhs.publicIp
            && lhs.publicIp?.hasLocation() == rhs.publicIp?.hasLocation()
            && lhs.isFetchingIp == rhs.isFetchingIp
            && lhs.activeNetworkInterfaces == rhs.activeNetworkInterfaces
            && lhs.physicalNetworkInterfaces == rhs.physicalNetworkInterfaces
            && lhs.hasDnsLeak == rhs.hasDnsLeak
            && lhs.hasWebRtcLeak == rhs.hasWebRtcLeak
        }
    }
    
    private func reactivateIpApis() {
        let updatedApis = userData.ipApis.map { api -> IpApiInfo in
            var mutable = api
            if !mutable.isActive() { mutable.active = true }
            return mutable
        }
        if updatedApis != userData.ipApis {
            userData.ipApis = updatedApis
        }
    }
}

extension AppState {
    struct UserData: Settable, Equatable {
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
                    key: Constants.settingsKeyApisRemoved)
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
        
        var closingApps = [AppInfo]() {
            didSet {
                writeSettingsArray(
                    newValues: closingApps,
                    key: Constants.settingsKeyClosingApps
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
        
        var useExtendedIpAddressInfo: Bool = true {
            didSet {
                writeSetting(
                    newValue: useExtendedIpAddressInfo,
                    key: Constants.settingsKeyuseExtendedIpAddressInfo
                )
            }
        }
        
        var periodicIpCheck: Bool = false {
            didSet {
                writeSetting(
                    newValue: periodicIpCheck,
                    key: Constants.settingsKeyPeriodicIpCheck)
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
                    key: Constants.settingsKeyHiddenMenuBarItems
                )
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
            lhs.menuBarUseThemeColor == rhs.menuBarUseThemeColor
        }
        
        init() {
            useExtendedProtection = readSetting(key: Constants.settingsKeyExtendedProtection) ?? false
            intervalBetweenChecks = readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? Constants.defaultIntervalBetweenChecksInSeconds
            useExtendedIpAddressInfo = readSetting(key: Constants.settingsKeyuseExtendedIpAddressInfo) ?? true
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
                key: Constants.settingsKeyClosingApps) {
                closingApps = savedAppsToClose
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
                    excluding: menuBarShownItems.filter { !$0.isSeparator() }
                )
            }
        }
        
        func getRandomActiveIpApi() -> IpApiInfo? {
            ipApis.filter { $0.isActive() }.randomElement()
        }
        
        func hasActiveIpApi() -> Bool {
            !ipApis.isEmpty && ipApis.contains(where: { $0.isActive() })
        }
        
        func getDefaultIpApis() -> [IpApiInfo] {
            Constants.ipApiUrls.map { IpApiInfo(url: $0, active: true) }
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
        monitoring.isEnabled
        && (system.locationServicesEnabled
            || network.hasDnsLeak
            || network.hasWebRtcLeak)
    }
    
    private func isCountryDetected() -> Bool {
        network.publicIp != nil
        && !network.publicIp!.countryName.isEmpty
    }
    
    private func findMainInterface() -> String {
        for active in network.activeNetworkInterfaces {
            for physical in network.physicalNetworkInterfaces {
                if active.name == physical.name
                { return active.name }
            }
        }
        return current.mainNetworkInterface
    }
    
    private func isDnsLeakCheckEnabled() -> Bool {
        monitoring.isEnabled
        && userData.dnsLeakCheck
        && network.status == .on
        && network.isVpnConnected
    }
    
    private func isWebRtcLeakCheckEnabled() -> Bool {
        monitoring.isEnabled
        && userData.webRtcLeakCheck
        && network.status == .on
        && network.isVpnConnected
    }
}
