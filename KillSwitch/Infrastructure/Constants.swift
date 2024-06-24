//
//  Constants.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.06.2024.
//

import Foundation

struct Constants{
    // MARK: Default values
    static let settings = "Settings"
    static let none = "None"
    static let primaryNetworkInterfaceName = "en0"
    static let minTimeIntervalToCheck: Double = 1
    static let maxTimeIntervalToCheck: Double = 3600
    static let zshPath = "/bin/zsh"
    static let launchAgentName = "user.launchkeep.KillSwitch"
    static let launchAgentPlistName = "user.launchkeep.KillSwitch.plist"
    static let launchAgentsFolderPath = "~/Library/LaunchAgents/"
    static let logDateFormat = "dd.MM.yyyy HH:mm:ss"
    static let networkMonitorQueryLabel = "KSNetworkMonitor"
    static let enabled = "enabled"
    static let disabled = "disabled"
    static let ipV4: Int = 4
    static let ipV6: Int = 6
    
    // MARK: Regexes
    static let regexUrl = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
    
    // MARK: Icons
    static let iconCompleteSafety = "checkmark.shield.fill"
    static let iconSomeSafety = "exclamationmark.shield.fill"
    static let iconUnsafe = "xmark.shield.fill"
    
    // MARK: Window IDs
    static let windowIdMain = "main-view"
    static let windowIdSettings = "settings-view"
    
    // MARK:  Settings key names
    static let settingsKeyAddresses = "allowed-addresses"
    static let settingsKeyApis = "apis"
    static let settingsKeyIsMonitoringEnabled = "is-monitoring-enabled"
    static let settingsKeyHigherProtection = "higher-protection"
    static let settingsKeyUsePickyMode = "use-picky-mode"
    static let settingsIntervalBetweenChecks = "interval-between-checks"
    
    // MARK: Shell commands
    static let shCommandEnableNetworkIterface = "networksetup -setairportpower %1$@ on"
    static let shCommandDisableNetworkIterface = "networksetup -setairportpower %1$@ off"
    static let shCommandLoadLaunchAgent = "launchctl load %1$@%2$@"
    static let shCommandEnableLaunchAgent = "launchctl enable %1$@"
    static let shCommandRemoveLaunchAgent = "launchctl remove %1$@"
    static let shCommandToggleLocationServices = "defaults -currentHost write '/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd' LocationServicesEnabled -bool %1$@"
    
    // MARK: Dialog messages
    static let dialogHeaderIpAddressIsNotValid = "IP Address is not valid"
    static let dialogBodyIpAddressIsNotValid = "IP Address seems to not be valid and cannot be added."
    static let dialogHeaderApiIsNotValid = "API for getting IP Address is not valid"
    static let dialogBodyApiIsNotValid = "API doesn't return a valid IP address as a plain text and cannot be added."
    static let dialogButtonOk = "OK"
    static let dialogHeaderLocationServicesToggled = "Location services"
    static let dialogBodyLocationServicesToggled = "It's needed to reboot the computer to apply Location services changes."
    static let dialogButtonRebootNow = "Reboot now"
    static let dialogButtonLater = "Later"
    
    // MARK: Log messages
    static let logMonitoringHasBeenEnabled = "Monitoring has been enabled."
    static let logMonitoringHasBeenDisabled = "Monitoring has been disabled."
    static let logCurrentIp = "Current IP is %1$@."
    static let logNoActiveAddressApiFound = "No any active address API found, add a new one in the Settings."
    static let logCurrentIpHasBeenUpdated = "Current IP has been updated to %1$@."
    static let logCurrentIpHasBeenUpdatedWithNotFromWhitelist = "Current IP address has been changed to %1$@ which is not from allowed IPs, network disabled."
    static let logErrorWhenCallingIpInfoApi = "Error when called IP info API: %1$@"
    static let logErrorWhenCallingIpAddressApi = "Error when called IP address API '%1$@': '%2$@', API marked as inactive and will be skipped until next application run."
    static let logNetworkInterfaceHasBeenEnabled = "Network interface '%1$@' has been enabled."
    static let logNetworkInterfaceHasBeenDisabled = "Network interface '%1$@' has been disabled."
    static let logCannotEnableNetworkInterface = "Cannot enable network interface '%1$@'."
    static let logCannotDisableNetworkInterface = "Cannot disable network interface '%1$@'."
    static let logLaunchAgentAdded = "Launch agent added, the application will be always running."
    static let logLaunchAgentRemoved = "Launch agent removed, the application won't be always running."
    static let logCannotAddLaunchAgent = "Cannot add Launch agent: %1$@."
    static let logCannotRemoveLaunchAgent = "Cannot remove Launch agent: %1$@."
    static let logLocationServicesHaveBeenToggled = "Location services have been %1$@, needs to restart to take effect."
    static let logCannotToggleLocationServices = "Cannot toggle location services: %1$@"
    static let logRebooting = "Rebooting..."
    static let logCannotReboot = "Cannot reboot the computer: %1$@"
    
    // MARK: Hints
    static let hintApiIsActive = "API is active and in use"
    static let hintApiIsInactive = "API is not active and not in use"
    
    // MARK: Static data
    static let addressApiUrls = [
        "http://api.ipify.org",
        "http://icanhazip.com",
        "http://ipinfo.io/ip",
        "http://ipecho.net/plain",
        "http://ident.me",
        "https://checkip.amazonaws.com",
        "http://whatismyip.akamai.com",
        "https://ip.istatmenus.app",
        "https://api.seeip.org"
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
}
