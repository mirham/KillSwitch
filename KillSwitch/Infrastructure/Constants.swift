//
//  Constants.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.06.2024.
//

import Foundation

struct Constants{
    // MARK: Default values
    static let defaultCountryCode = "US"
    static let defaultIpAddress = "1.1.1.1"
    static let secondInNanoseconds: UInt64 = 1_000_000_000
    static let defaultMonitoringInterval: Int = 1
    static let defaultMonitoringIntervalNanoseconds: UInt64 =  UInt64(defaultMonitoringInterval) * secondInNanoseconds
    static let defaultProcessesMonitoringInterval: Int = 5
    static let defaultProcessesMonitoringIntervalNanoseconds: UInt64 =  UInt64(defaultProcessesMonitoringInterval) * secondInNanoseconds
    static let defaultCheckConnectionIntervalSeconds: Int = 5
    static let defaultCheckConnectionIntervalNanoseconds: UInt64 = UInt64(defaultCheckConnectionIntervalSeconds * 1_000_000_000)
    static let minTimeIntervalToCheck: Int = 1
    static let maxTimeIntervalToCheck: Int = 300
    static let callTimeoutIpApiInSeconds: Double = 1.0
    static let callTimeoutIpApiTotalInSeconds: Double = 20.0
    static let callTimeoutIpInfoApiInSeconds: Double = 2.0
    static let zshPath = "/bin/zsh"
    static let headHttpMethod = "HEAD"
    static let launchAgentName = "\(Bundle.main.bundleIdentifier!)"
    static let launchAgentPlistName = "\(Bundle.main.bundleIdentifier!).plist"
    static let launchAgents = "LaunchAgents"
    static let launchAgentsFolderPath = "~/Library/LaunchAgents/"
    static let logDateFormat = "dd.MM.yyyy HH:mm:ss"
    static let networkMonitorQueryLabel = "KSNetworkMonitor"
    static let ipV4: Int = 4
    static let ipV6: Int = 6
    static let minIpApiCount: Int = 1
    static let defaultToleranceInNanoseconds: UInt64 = 100_000_000
    static let menuBarItemTimeToleranceInSeconds: Int = 1
    static let defaultIntervalBetweenChecksInSeconds: Int = 10
    static let ipApiCallTimeoutInSeconds: Double = 1.0
    static let ipInfoApiCallTimeoutInSeconds: Double = 2.0
    static let memuBarScaleCurrentIp = 0.9
    static let memuBarScaleToggles = 0.8
    static let physicalNetworkInterfacePrefix = "en"
    static let physicalNetworkInterfaceWiFi = "Wi-Fi"
    static let physicalNetworkInterfaceLan = "LAN"
    static let physicalNetworkInterfaceExclusion = "Thunderbolt"
    static let sleepPreventingReason = "Monitoring sleep preventing"
    static let defaultInternetCheckUrl = "https://google.com"
    static let defaultIpInfoApiUrl = "http://ip-api.com/json/\(publicIpMask)"
    
    // MARK: Regexes
    static let regexUrl = /(?<protocol>https?):\/\/(?:(?<username>[^:@\s\/\\]*)(?::(?<password>[^:@\s\/\\]*))?@)?(?<domain>[\w\d]+[\w\d.\-]+[\w\d]+|\[[a-f\d:]+\])(?::(?<port>\d+))?(?:(?<path>\/[^\?#\s]*)(?:\?(?<query>[^\?#\s]*))?(?:#(?<anchor>[^\?#\s]*))?)?/
    
    // MARK: Masks
    static let publicIpMask = "%IP%"
    
    // MARK: Icons
    static let iconApp = "AppIcon"
    static let iconCompleteSafety = "checkmark.shield.fill"
    static let iconSomeSafety = "exclamationmark.shield.fill"
    static let iconUnsafe = "xmark.shield.fill"
    static let iconWindow = "macwindow"
    static let iconQuit = "xmark.circle"
    static let iconSettings = "gearshape.2"
    static let iconQuestionMark = "questionmark.circle.fill"
    static let iconCopyLog = "doc.on.doc"
    static let iconClearLog = "trash"
    static let iconInfo = "info.circle"
    static let iconCellular = "cellularbars"
    static let iconLoopback = "point.forward.to.point.capsulepath"
    static let iconVpn = "network.badge.shield.half.filled"
    static let iconWifi = "wifi"
    static let iconWired = "cable.connector"
    static let iconUnknownConnection = "questionmark"
    static let iconInfoFill = "info.circle.fill"
    static let iconCheckmark = "checkmark.circle.fill"
    static let iconCircle = "circle"
    static let iconMarkedCircle = "largecircle.fill.circle"
    static let iconNoActiveIpApi = "exclamationmark.triangle.fill"
    
    // MARK: Colors
    static let colorCompleteSafetyLightTheme = "#369300"
    static let colorSomeSafetyLightTheme = "#A7A200"
    
    // MARK: Window IDs
    static let windowIdMain = "main-view"
    static let windowIdMenuBar = "menubar-view"
    static let windowIdSettings = "settings-view"
    static let windowIdKillProcessesConfirmationDialog = "kill-processess-confirmation-dialog-view"
    static let windowIdEnableNetworkDialog = "enable-network-dialog-view"
    static let windowIdNoOneAllowedIpDialog = "no-one-allowed-ip-dialog-view"
    static let windowIdInfo = "info-view"
    
    // MARK: Elements names
    static let settings = "Settings"
    static let info = "Info"
    static let show = "Show"
    static let quit = "Quit"
    static let none = "None"
    static let offline = "Offline"
    static let on = "On"
    static let off = "Off"
    static let add = "Add"
    static let copy = "Copy"
    static let edit = "Edit"
    static let delete = "Delete"
    static let enable = "Enable"
    static let cancel = "Cancel"
    static let close = "Close"
    static let save = "Save"
    static let yes = "Yes"
    static let no = "No"
    static let ok = "OK"
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
    static let publicIp = "Public IP"
    static let enabled = "enabled"
    static let disabled = "disabled"
    static let physical = "physical"
    static let virtual = "virtual"
    static let checked = "Checked"
    static let unchecked = "Unchecked"
    static let ipInfoApiUrl = "IP info API address (use \(publicIpMask) for public IP address)"
    static let mappings = "Mappings"
    static let noActiveIpApi = "No active IP API"
    static let obtainingIp = "Obtaining IP..."
    
    // MARK: Symbols
    static let bullet = "•"
    static let pipe = "|"
    static let leftBracket = "("
    static let rightBracket = ")"
    
    // MARK: Toolbar
    static let toolbarSettings = "Settings"
    static let toolbarCopyLog = "Copy log"
    static let toolbarClearLog = "Clear log"
    static let toolbarInfo = "Info"
    
    // MARK: Menu items
    static let menuItemCopy = "Copy"
    static let menuItemAddAsAllowedIpWithCompletePrivacy = "Add as allowed IP with complete privacy"
    static let menuItemAddAsAllowedIpWithSomePrivacy = "Add as allowed IP with some privacy"
    
    // MARK: Settings elements names
    static let settingsElementGeneral = "General"
    static let settingsElementMenubar = "Menu bar"
    static let settingsElementShownItems = "Shown menu bar items"
    static let settingsElementAvailableItems = "Available menu bar items"
    static let settingsElementAllowedIpAddresses = "Allowed IPs"
    static let settingsElementIpAddressApis = "IP APIs"
    static let settingsElementIpInfoApi = "IP info API"
    static let settingsElementClosingApps = "Closing apps"
    static let settingsElementClosingApplications = "Closing applications"
    static let settingsElementKeepAppRunning = "Keep application running"
    static let settingsElementOnTopOfAllWindows = "Always on top of all windows"
    static let settingsElementDisableLocationServices = "Disable location services"
    static let settingsElementPreventComputerSleep = "Preventing the computer from going to sleep"
    static let settingsElementHigherProtection = "Higher protection"
    static let settingsElementPickyMode = "Picky mode"
    static let settingsElementPeriodicIpCheck = "Periodic IP address check"
    static let settingsElementAutoCloseApps = "Automatically close applications"
    static let settingsElementConfirmationToCloseApps = "Confirmation to close applications"
    static let settingsElementIntervalBegin = "at intervals of"
    static let settingsElementIntervalEnd = "second(s)"
    static let settingsElementThemeColor = "Use system theme color"
    
    // MARK:  Settings key names
    static let settingsKeyIps = "allowed-addresses"
    static let settingsKeyApis = "apis"
    static let settingsKeyIsMonitoringEnabled = "is-monitoring-enabled"
    static let settingsKeyHigherProtection = "higher-protection"
    static let settingsKeyUsePickyMode = "use-picky-mode"
    static let settingsKeyPeriodicIpCheck = "periodic-ip-check"
    static let settingsKeyIntervalBetweenChecks = "interval-between-checks"
    static let settingsKeyAppsToClose = "apps-to-close"
    static let settingsKeyAutoCloseApps = "auto-close-apps"
    static let settingsKeyConfirmationApplicationsClose = "confirmation-apps-close"
    static let settingsKeyShownMenuBarItems = "shown-menubar-items"
    static let settingsKeyHiddenMenuBarItems = "hidden-menubar-items"
    static let settingsKeyMenuBarUseThemeColor = "menubar-use-theme-color"
    static let settingsKeyOnTopOfAllWindows = "on-top-of-all-windows"
    static let settingsKeyPreventComputerSleep = "prevent-computer-sleep"
    static let settingsKeyIpInfoApiUrl = "ip-info-api-url"
    static let settingsKeyIpInfoMapping = "ip-info-api-matches"
    
    // MARK: Menubar item keys
    static let mbItemKeyShield = "shiled"
    static let mbItemKeyMonitoringStatus = "monitoring-status"
    static let mbItemKeyIpAddress = "ip-address"
    static let mbItemKeyCountryCode = "country-code"
    static let mbItemKeyCountryFlag = "country-flag"
    static let mbItemKeySeparatorBullet = "separator-bullet"
    static let mbItemKeySeparatorPipe = "separator-pipe"
    static let mbItemKeySeparatorLeftBracket = "separator-left-bracket"
    static let mbItemKeySeparatorRightBracket = "separator-right-bracket"
    
    // MARK: Shell commands
    static let shCommandEnableNetworkIterface = "networksetup -setairportpower %1$@ on"
    static let shCommandDisableNetworkIterface = "networksetup -setairportpower %1$@ off"
    static let shCommandLoadLaunchAgent = "launchctl load %1$@%2$@"
    static let shCommandEnableLaunchAgent = "launchctl enable %1$@"
    static let shCommandRemoveLaunchAgent = "launchctl remove %1$@"
    static let shCommandToggleLocationServices = "defaults -currentHost write '/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd' LocationServicesEnabled -bool %1$@"
    static let shCommandReboot = "reboot"
    
    // MARK: Error messages
    static let errorNoActiveIpApiFound = "Not possible to obtain IP, try to add a new IP API in the Settings to proceed work or check DNS availability"
    static let errorWhenCallingIpAddressApi = "Error when called IP address API '%1$@': '%2$@', API marked as inactive and will be skipped until next application run"
    static let errorIpApiResponseIsInvalid = "IP address API returned invalid IP address"
    static let errorWhenCallingIpInfoApi = "Error when called IP info API: %1$@"
    static let errorTaskCancelled = "Task cancelled"
    static let errorInvalidJson = "Invalid JSON"
    
    // MARK: Dialogs
    static let dialogHeaderIpIsNotValid = "IP Address is not valid"
    static let dialogBodyIpIsNotValid = "IP Address seems to not be valid and cannot be added."
    static let dialogHeaderApiIsNotValid = "API for getting IP Address is not valid"
    static let dialogBodyApiIsNotValid = "API doesn't return a valid IP address as a plain text and cannot be added."
    static let dialogHeaderLocationServicesToggled = "Location services"
    static let dialogBodyLocationServicesToggled = "It's needed to reboot the computer to apply Location services changes."
    static let dialogButtonRebootNow = "Reboot now"
    static let dialogHeaderCannotAddAppToClose = "Cannot add application to close."
    static let dialogBodyCannotAddAppToClose = "Cannot add application to close: %1$@"
    static let dialogHeaderCloseApps = "Close applications"
    static let dialogBodyCloseApps = "Are you sure you want to close these applications?\nThis operation cannot be undone."
    static let dialogHeaderEnableNetwork = "Enable network"
    static let dialogBodyEnableNetwork = "Select a network interface to enable:\n"
    static let dialogHeaderNoOneAllowedIp = "No allowed IP addresses are configured"
    static let dialogBodyNoOneAllowedIpIfOffline = "Add one or more in the settings\n"
    static let dialogBodyNoOneAllowedIpIfOnline = "Select a privacy type for the current IP address if you want to add it as an allowed one, or add one or more manually in the settings later\n"
    static let dialogHeaderLastAllowedIpDeleting = "Last allowed IP address deleting"
    static let dialogBodyLastAllowedIpDeleting = "IP address %1$@ is the last allowed one. The monitoring will be stopped. Are you sure you want to continue?"
    static let dialogHeaderIpInfoApiIsNotValid = "API for getting information of public IP address is not valid"
    static let dialogBodyIpInfoApiIsNotValid = "API doesn't return a JSON data and cannot be added."
    static let dialogHeaderIpInfoApiMappingIsNotValid = "API for getting information of public IP address doesn't return required data."
    static let dialogBodyIpInfoApiMappingIsNotValid = "The API does not return the country code or country name. Please double-check the API values and mapping for correctness."
    static let dialogHeaderLastIpApiCannotBeRemoved = "Cannot remove the last remaining IP API"
    static let dialogBodyLastIpApiCannotBeRemoved = "You're trying to remove the last IP API, which will make the application stop working. To keep the app functional, please add more valid IP APIs (as many as possible) before deleting this one."
    
    // MARK: Log messages
    static let logMonitoringHasBeenEnabled = "Monitoring enabled"
    static let logMonitoringHasBeenDisabled = "Monitoring disabled"
    static let logPublicIp = "Public IP is %1$@ (location: %2$@)"
    static let logPublicIpHasBeenUpdated = "Public IP has been updated to %1$@"
    static let logPublicIpHasBeenUpdatedWithNotFromWhitelist = "Public IP address has been changed to %1$@ which is not from allowed IPs, network disabled"
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
    static let logErrorHandlingProcesses = "Error when handling active processes: %1$@"
    static let logPreventComputerSleepEnabled = "Preventing the computer from going to sleep is enabled"
    static let logPreventComputerSleepDisabled = "Preventing the computer from going to sleep is disabled"
    
    // MARK: Hints
    static let hintApiIsActive = "API is in use"
    static let hintApiIsInactive = "API not used"
    static let hintNewVaildIpAddress = "A new valid IP address"
    static let hintNewVaildUrl = "A new valid URL"
    static let hintNewVaildApiUrl = "A new valid API URL"
    static let hintClickToEnableNetwork = "Click to enable network"
    static let hintClickToDisableNetwork = "Click to disable network"
    static let hintClickToEnableMonitoring = "Click to enable monitoring"
    static let hintClickToDisableMonitoring = "Click to disable monitoring"
    static let hintKeepApplicationRunning = "The application will be opened after the system starts or if it was closed."
    static let hintOnTopOfAllWindows = "Put application windows on top of all other windows."
    static let hintToggleLocationServices = "Toggle location services after restart. If the required state is critical, this can be done manually in Settings → Privacy & Security → Location Services without restarting."
    static let hintPreventComputerSleep = "Preventing the computer from going to sleep when monitoring is enabled."
    static let hintHigherProtection = "Disable the network when monitoring is enabled, if there is no reliable information about the current IP address. Also close all running monitored applications, if any."
    static let hintAutoCloseApps = "Force close applications when monitoring is enabled and current IP address is unsafe. The confirmation dialog option when closing applications will be ignored."
    static let hintCloseApplicationConfirmation = "Confirmation dialog when closing applications. This option is ignored in higher protection mode."
    static let hintPickyMode = "Use extended information about current IP address, such as country. Does not allow the use of an IP address as an allowed one if there is no reliable information about it."
    static let hintPeriodicIpCheck = "Check the public IP address periodically when monitoring is enabled at the interval specified below."
    static let hintInterval = "\(minTimeIntervalToCheck)..\(maxTimeIntervalToCheck)"
    static let hintMenuBarAdjustment = "Drag menu bar item icons between the sections below to arrange item as you want"
    static let hintAllowedIps = "Add an allowed IP address with desired safety type\nRight click on the address to display the context menu"
    static let hintIpApis = "Add an API that returns the public IP address in plain text\nRight click on the API to display the context menu\nIf API marked green, it works properly and in use"
    static let hintCloseApps = "Add the application you want to close automatically or manually\nRight click on the application to display the context menu"
    static let hintIpInfoApi = "The IP info API is needed to get advanced information about a public IP address, such as its location. This allows you to display the country flag in the macOS menu bar, as well as show the address on a map. Typically, data from such APIs is in JSON format. Here, you can assign an API address and map the JSON data values to application values."
    static let hintNotSet = "Not set yet"
    static let hintJsonKey = "JSON data key"
    
    // MARK: About
    static let aboutSupportMail = "bWlyaGFtQGFidi5iZw=="
    static let aboutGitHubLink = "https://github.com/mirham/KillSwitch"
    
    static let aboutBackground = "AppInfo"
    
    static let aboutVersionKey = "CFBundleShortVersionString"
    static let aboutGetSupport = "Get support:"
    static let aboutVersion = "Version: %1$@"
    static let aboutMailTo = "mailto:%1$@"
    static let aboutGitHub = "GitHub"
    
    // MARK: Static data
    static let ipApiUrls = [
        "http://api.ipify.org",
        "http://icanhazip.com",
        "http://ipinfo.io/ip",
        "http://ipecho.net/plain",
        "https://checkip.amazonaws.com",
        "http://whatismyip.akamai.com",
        "https://api.seeip.org",
        "https://ipapi.co/ip",
        "https://4.ident.me/",
        "https://www.myexternalip.com/raw",
        "https://l2.io/ip",
        "https://api.ip.sb/ip",
        "https://ipv4.ddnspod.com/",
        "https://api.ip.lk/"
    ]
    
    static let defaultIpInfoApiKeyMapping = [
        "ipAddress" : "query",
        "countryCode" : "countryCode",
        "countryName" : "country",
    ]
    
    static let readableIpInfoApiKeyMapping = [
        "ipAddress" : "IP address",
        "countryCode" : "Country code",
        "countryName" : "Country name"
    ]
    
    static let launchAgentXmlContent =
        """
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(Bundle.main.bundleIdentifier!)</string>
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
    
    static let defaultShownMenuBarItems = [
        mbItemKeyShield,
        mbItemKeyMonitoringStatus
    ]
    
    static let defaultHiddenMenuBarItems = [
        mbItemKeyIpAddress,
        mbItemKeyCountryFlag,
        mbItemKeyCountryCode,
        mbItemKeySeparatorBullet,
        mbItemKeySeparatorPipe,
        mbItemKeySeparatorLeftBracket,
        mbItemKeySeparatorRightBracket
    ]
}
