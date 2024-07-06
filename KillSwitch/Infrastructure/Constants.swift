//
//  Constants.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.06.2024.
//

import Foundation

struct Constants{
    // MARK: Default values
    static let primaryNetworkInterfaceName = "en0"
    static let minTimeIntervalToCheck: Double = 1
    static let maxTimeIntervalToCheck: Double = 3600
    static let zshPath = "/bin/zsh"
    static let launchAgentName = "user.launchkeep.KillSwitch"
    static let launchAgentPlistName = "user.launchkeep.KillSwitch.plist"
    static let launchAgents = "LaunchAgents"
    static let launchAgentsFolderPath = "~/Library/LaunchAgents/"
    static let logDateFormat = "dd.MM.yyyy HH:mm:ss"
    static let networkMonitorQueryLabel = "KSNetworkMonitor"
    static let enabled = "enabled"
    static let disabled = "disabled"
    static let ipV4: Int = 4
    static let ipV6: Int = 6
    static let utun = "utun"
    static let defaultIntervalBetweenChecksInSeconds: Double = 10
    
    // MARK: Regexes
    static let regexUrl = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
    
    // MARK: Icons
    static let iconApp = "AppIcon"
    static let iconCompleteSafety = "checkmark.shield.fill"
    static let iconSomeSafety = "exclamationmark.shield.fill"
    static let iconUnsafe = "xmark.shield.fill"
    static let iconWindow = "macwindow"
    static let iconQuit = "xmark.circle"
    static let iconSettings = "gearshape.2"
    
    // MARK: Window IDs
    static let windowIdMain = "main-view"
    static let windowIdSettings = "settings-view"
    static let windowIdKillProcessesConfirmationDialog = "kill-processess-confirmation-dialog-view"
    
    // MARK: Elements names
    static let settings = "Settings"
    static let show = "Show"
    static let quit = "Quit"
    static let none = "None"
    static let on = "On"
    static let off = "Off"
    static let add = "Add"
    static let delete = "Delete"
    static let yes = "Yes"
    static let no = "No"
    static let ok = "OK"
    static let wait = "Wait"
    static let na = "N/A"
    static let later = "Later"
    static let ip = "IP"
    static let apiUrl = "API URL"
    static let safety = "Safety"
    static let network = "Network"
    static let monitoring = "Monitoring"
    static let applications = "Applications"
    static let clickToClose = "Click to close"
    static let activeConnections = "Active connections"
    static let safetyDescriprion = "%1$@ safety"
    static let disableLocationServices = "(disable location services)"
    static let currentIp = "Current IP"
    
    // MARK: Menu items
    
    static let menuItemCopy = "Copy"
    static let menuItemAddAsAllowedIpWithCompletePrivacy = "Add as allowed IP with complete privacy"
    static let menuItemAddAsAllowedIpWithSomePrivacy = "Add as allowed IP with some privacy"
    
    // MARK: Settings elements names
    static let settingsElementGeneral = "General"
    static let settingsElementAllowedIpAddresses = "Allowed IP addresses"
    static let settingsElementIpAddressApis = "IP address APIs"
    static let settingsElementAppsToClose = "Apps to close"
    static let settingsElementApplicationsToClose = "Applications to close"
    
    // MARK:  Settings key names
    static let settingsKeyAddresses = "allowed-addresses"
    static let settingsKeyApis = "apis"
    static let settingsKeyIsMonitoringEnabled = "is-monitoring-enabled"
    static let settingsKeyHigherProtection = "higher-protection"
    static let settingsKeyUsePickyMode = "use-picky-mode"
    static let settingsKeyIntervalBetweenChecks = "interval-between-checks"
    static let settingsKeyAppsToClose = "apps-to-close"
    static let settingsKeyConfirmationApplicationsClose = "confirmation-apps-close"
    
    // MARK: Shell commands
    static let shCommandEnableNetworkIterface = "networksetup -setairportpower %1$@ on"
    static let shCommandDisableNetworkIterface = "networksetup -setairportpower %1$@ off"
    static let shCommandLoadLaunchAgent = "launchctl load %1$@%2$@"
    static let shCommandEnableLaunchAgent = "launchctl enable %1$@"
    static let shCommandRemoveLaunchAgent = "launchctl remove %1$@"
    static let shCommandToggleLocationServices = "defaults -currentHost write '/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd' LocationServicesEnabled -bool %1$@"
    static let shCommandReboot = "reboot"
    
    // MARK: Error messages
    static let errorNoActiveAddressApiFound = "No active IP address API found, add a new one in the Settings"
    static let errorWhenCallingIpAddressApi = "Error when called IP address API '%1$@': '%2$@', API marked as inactive and will be skipped until next application run"
    static let errorIpApiResponseIsInvalid = "IP address API returned invalid IP address"
    static let errorWhenCallingIpInfoApi = "Error when called IP info API: %1$@"
    
    // MARK: Dialogs
    static let dialogHeaderIpAddressIsNotValid = "IP Address is not valid"
    static let dialogBodyIpAddressIsNotValid = "IP Address seems to not be valid and cannot be added."
    static let dialogHeaderApiIsNotValid = "API for getting IP Address is not valid"
    static let dialogBodyApiIsNotValid = "API doesn't return a valid IP address as a plain text and cannot be added."
    static let dialogHeaderLocationServicesToggled = "Location services"
    static let dialogBodyLocationServicesToggled = "It's needed to reboot the computer to apply Location services changes."
    static let dialogButtonRebootNow = "Reboot now"
    static let dialogHeaderCannotAddAppToClose = "Cannot add application to close."
    static let dialogBodyCannotAddAppToClose = "Cannot add application to close: %1$@"
    static let dialogHeaderCloseApps = "Close applications"
    static let dialogBodyCloseApps = "Are you sure you want to close these applications?\nThis operation cannot be undone."
    
    // MARK: Log messages
    static let logMonitoringHasBeenEnabled = "Monitoring has been enabled"
    static let logMonitoringHasBeenDisabled = "Monitoring has been disabled"
    static let logCurrentIp = "Current IP is %1$@"
    static let logCurrentIpHasBeenUpdated = "Current IP has been updated to %1$@"
    static let logCurrentIpHasBeenUpdatedWithNotFromWhitelist = "Current IP address has been changed to %1$@ which is not from allowed IPs, network disabled"
    static let logNetworkInterfaceHasBeenEnabled = "Network interface '%1$@' has been enabled"
    static let logNetworkInterfaceHasBeenDisabled = "Network interface '%1$@' has been disabled"
    static let logCannotEnableNetworkInterface = "Cannot enable network interface '%1$@'"
    static let logCannotDisableNetworkInterface = "Cannot disable network interface '%1$@'"
    static let logLaunchAgentAdded = "Launch agent added, the application will be always running"
    static let logLaunchAgentRemoved = "Launch agent removed, the application won't be always running"
    static let logCannotAddLaunchAgent = "Cannot add Launch agent: %1$@"
    static let logCannotRemoveLaunchAgent = "Cannot remove Launch agent: %1$@"
    static let logLocationServicesHaveBeenToggled = "Location services have been %1$@, needs to restart to take effect"
    static let logCannotToggleLocationServices = "Cannot toggle location services: %1$@"
    static let logRebooting = "Rebooting..."
    static let logCannotReboot = "Cannot reboot the computer: %1$@"
    static let logProcessTerminated = "%1$@ has been closed"
    
    // MARK: Hints
    static let hintApiIsActive = "API is active and in use"
    static let hintApiIsInactive = "API is not active and not in use"
    static let hintNewVaildIpAddress = "A new valid IP address"
    static let hintNewVaildApiUrl = "A new valid API URL"
    static let hintClickToEnableNetwork = "Click to enable network"
    static let hintClickToDisableNetwork = "Click to disable network"
    static let hintClickToEnableMonitoring = "Click to enable monitoring"
    static let hintClickToDisableMonitoring = "Click to disable monitoring"
    
    // MARK: Static data
    static let ipApiUrls = [
        "http://api.ipify.org",
        "http://icanhazip.com",
        "http://ipinfo.io/ip",
        "http://ipecho.net/plain",
        "https://checkip.amazonaws.com",
        "http://whatismyip.akamai.com",
        "https://ip.istatmenus.app",
        "https://api.seeip.org",
        "https://ipapi.co/ip"
    ]
    
    static let launchAgentXmlContent =
        """
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>user.launchkeep.KillSwitch</string>
                <key>KeepAlive</key>
                <true/>
                <key>Program</key>
                <string>%1$@</string>
            </dict>
        </plist>
        """;
    
    static let vpnProtocols = [
        "tap", 
        "tun",
        "ppp",
        "ipsec",
        "utun"
    ]
}
