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
    static let networkMonitorQueryLabel = "KSNetworkMonitor"
    static let ipV4: Int = 4
    static let ipV6: Int = 6
    static let minIpApiCount: Int = 1
    static let defaultRetryCount: Int = 3
    static let defaultToleranceInNanoseconds: UInt64 = 100_000_000
    static let menuBarItemTimeToleranceInSeconds: Int = 1
    static let defaultIntervalBetweenChecksInSeconds: Int = 10
    static let ipApiCallTimeoutInSeconds: Double = 1.0
    static let ipInfoApiCallTimeoutInSeconds: Double = 2.0
    static let menuBarScaleCurrentIp = 0.95
    static let menuBarScaleToggles = 0.8
    static let physicalNetworkInterfacePrefix = "en"
    static let physicalNetworkInterfaceWiFi = "Wi-Fi"
    static let physicalNetworkInterfaceLan = "LAN"
    static let physicalNetworkInterfaceExclusion = "Thunderbolt"
    static let sleepPreventingReason = "Monitoring sleep preventing"
    static let defaultInternetCheckUrl = "https://google.com"
    static let defaultIpInfoApiUrl = "http://ip-api.com/json/\(publicIpMask)"
    static let libraryBasePath = NSHomeDirectory() + "/Library/"
    static let defaultDnsLeakCheckIntervalInSeconds: Int = 15
    static let defaultWebRtcLeakCheckIntervalInSeconds: Int = 10
    
    // MARK: HTTP methods
    static let httpMethodGet = "GET"
    
    // MARK: Regexes
    static let regexUrl = /(?<protocol>https?):\/\/(?:(?<username>[^:@\s\/\\]*)(?::(?<password>[^:@\s\/\\]*))?@)?(?<domain>[\w\d]+[\w\d.\-]+[\w\d]+|\[[a-f\d:]+\])(?::(?<port>\d+))?(?:(?<path>\/[^\?#\s]*)(?:\?(?<query>[^\?#\s]*))?(?:#(?<anchor>[^\?#\s]*))?)?/
    static let regexScutilParenthesesPattern = #"\(([^)]+)\)"#
    static let regexSeparator = "separator"
    
    // MARK: Masks
    static let publicIpMask = "%IP%"
    
    // MARK: Icons
    static let iconApp = "AppIcon"
    static let iconCompleteSecurity = "checkmark.shield.fill"
    static let iconSomeSecurity = "exclamationmark.shield.fill"
    static let iconNotSecure = "xmark.shield.fill"
    static let iconWindow = "macwindow"
    static let iconQuit = "xmark.circle"
    static let iconSettings = "gearshape.2"
    static let iconQuestionMark = "questionmark.circle.fill"
    static let iconCopyLog = "doc.on.doc"
    static let iconClearLog = "trash"
    static let iconInfo = "info.circle"
    static let iconInfoFill = "info.circle.fill"
    static let iconCellular = "cellularbars"
    static let iconLoopback = "point.forward.to.point.capsulepath"
    static let iconVpn = "network.badge.shield.half.filled"
    static let iconWifi = "wifi"
    static let iconWired = "cable.connector"
    static let iconOtherConnection = "questionmark"
    static let iconUnknownConnection = "network.slash"
    static let iconCheckmark = "checkmark.circle.fill"
    static let iconCircle = "circle"
    static let iconMarkedCircle = "largecircle.fill.circle"
    static let iconNoActiveIpApi = "exclamationmark.triangle.fill"
    static let iconFolder = "folder"
    static let iconGear = "gear"
    static let iconMenubar = "menubar.rectangle"
    static let iconNetwork = "network"
    static let iconBulletRectangle = "list.bullet.rectangle"
    static let iconClosingApps = "xmark.circle"
    static let iconEmptyLog = "text.alignleft"
    static let iconLeak = "humidity.fill"
    static let iconWarning = "exclamationmark.triangle.fill"
    static let iconMonitoring = "waveform.path.ecg"
    static let iconApps = "square.grid.2x2"
    static let iconExpandApps = "chevron.forward"
    static let iconLocation = "location.fill"
    static let iconGranted = "checkmark"
    static let iconDenied = "xmark"
    static let iconPermissions = "hand.raised"
    
    // MARK: Colors
    static let colorCompleteSecurityLightTheme = "#369300"
    static let colorSomeSecurityLightTheme = "#A7A200"
    static let colorOn = "#34C759"
    static let colorOff = "#8E8E93"
    static let colorWait = "#FF9F0A"
    
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
    static let security = "Security"
    static let network = "Network"
    static let monitoring = "Monitoring"
    static let applications = "Applications"
    static let clickToClose = "Click to close"
    static let activeConnections = "Active connections"
    static let securityDescriprion = "%1$@ security"
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
    static let fetchingIp = "Fetching IP..."
    static let all = "All"
    static let securityConcerns = "Security concerns"
    static let allow = "Allow"
    static let granted = "Granted"
    static let denied = "Denied"
    static let notDetermined = "Not determined"
    
    // MARK: Symbols
    static let dot = "."
    static let bullet = "•"
    static let pipe = "|"
    static let leftBracket = "("
    static let rightBracket = ")"
    static let slash = "/"
    static let doubleNewline = "\n\n"
    static let newline = "\n"
    static let colon = ":"
    static let parentheses = "()"
    static let nilPlaceholder = "nil"
    static let serverSeparator = ", "
    static let leakDetailSeparator = "; "
    static let space = " "
    
    // MARK: Toolbar
    static let toolbarSettings = "Settings"
    static let toolbarCopyLog = "Copy log"
    static let toolbarClearLog = "Clear log"
    static let toolbarInfo = "Info"
    static let toolbarLogEntrty = "%lld entry"
    static let toolbarLogEntries = "%lld entries"
    
    // MARK: Menu items
    static let menuItemCopy = "Copy"
    static let menuItemAddAsAllowedIpWithCompleteSecurity = "Add as allowed IP with complete security"
    static let menuItemAddAsAllowedIpWithSomeSecurity = "Add as allowed IP with some security"
    
    // MARK: Settings elements names
    static let settingsElementGeneral = "General"
    static let settingsElementMenubar = "Menu bar"
    static let settingsElementShownItems = "Shown menu bar items"
    static let settingsElementAvailableItems = "Available menu bar items"
    static let settingsElementAllowedIpAddresses = "Allowed IPs"
    static let settingsElementIpAddressApis = "IP APIs"
    static let settingsElementIpInfoApi = "IP info API"
    static let settingsElementLeaks = "Leaks"
    static let settingsElementPermissions = "Permissions"
    static let settingsElementClosingApps = "Closing apps"
    static let settingsElementClosingApplications = "Closing applications"
    static let settingsElementKeepAppRunning = "Keep application running"
    static let settingsElementOnTopOfAllWindows = "Always on top of all windows"
    static let settingsElementDisableLocationServices = "Disable location services"
    static let settingsElementPreventComputerSleep = "Preventing the computer from going to sleep"
    static let settingsElementExtendedProtection = "Extended protection"
    static let settingsElementPickyMode = "Extended IP address information required"
    static let settingsElementPeriodicIpCheck = "Periodic IP address check"
    static let settingsElementAutoCloseApps = "Automatically close applications"
    static let settingsElementConfirmationToCloseApps = "Confirmation to close applications"
    static let settingsElementIntervalBegin = "at intervals of"
    static let settingsElementIntervalEnd = "second(s)"
    static let settingsElementThemeColor = "Use system theme color"
    static let settingsElementPeriodicDnsLeakCheck = "Periodic DNS leak check"
    static let settingsElementPeriodicWebRtcLeakCheck = "Periodic WebRTC leak check"
    static let settingsElementOpenSettings = "Open settings"
    static let settingsElementLocationAccess = "Location access"
    
    // MARK:  Settings key names
    static let settingsKeyIps = "allowed-addresses"
    static let settingsKeyApis = "apis"
    static let settingsKeyApisRemoved = "apis-removed"
    static let settingsKeyIsMonitoringEnabled = "is-monitoring-enabled"
    static let settingsKeyExtendedProtection = "higher-protection"
    static let settingsKeyUsePickyMode = "use-picky-mode"
    static let settingsKeyPeriodicIpCheck = "periodic-ip-check"
    static let settingsKeyIntervalBetweenChecks = "interval-between-checks"
    static let settingsKeyAppsToClose = "apps-to-close"
    static let settingsKeyWebRtcMonitoredApps = "webrtc-mon-apps"
    static let settingsKeyAutoCloseApps = "auto-close-apps"
    static let settingsKeyConfirmationApplicationsClose = "confirmation-apps-close"
    static let settingsKeyShownMenuBarItems = "shown-menubar-items"
    static let settingsKeyHiddenMenuBarItems = "hidden-menubar-items"
    static let settingsKeyMenuBarUseThemeColor = "menubar-use-theme-color"
    static let settingsKeyOnTopOfAllWindows = "on-top-of-all-windows"
    static let settingsKeyPreventComputerSleep = "prevent-computer-sleep"
    static let settingsKeyIpInfoApiUrl = "ip-info-api-url"
    static let settingsKeyIpInfoMapping = "ip-info-api-matches"
    static let settingsKeyDnsLeakCheck = "dns-leak-check"
    static let settingsKeyDnsLeakCheckInterval = "dns-leak-check-interval"
    static let settingsKeyWebRtcLeakCheck = "webrtc-leak-check"
    static let settingsKeyWebRtcLeakCheckInterval = "webrtc-leak-check-interval"
    
    // MARK: Menubar item keys
    static let mbItemKeyShield = "shiled"
    static let mbItemKeyMonitoringStatus = "monitoring-status"
    static let mbItemKeyBullet = "bullet"
    static let mbItemKeyIpAddress = "ip-address"
    static let mbItemKeyCountryCode = "country-code"
    static let mbItemKeyCountryFlag = "country-flag"
    static let mbItemKeyVpn = "vpn"
    static let mbItemKeyLeak = "leak"
    static let mbItemKeySeparatorBullet = "separator-bullet"
    static let mbItemKeySeparatorPipe = "separator-pipe"
    static let mbItemKeySeparatorLeftBracket = "separator-left-bracket"
    static let mbItemKeySeparatorRightBracket = "separator-right-bracket"
    
    // MARK: Network interfaces info
    static let niiActiveServiceIPv4 = "State:/Network/Service/.*/IPv4"
    static let niiInterfaceStateIPv4 = "State:/Network/Interface/%@/IPv4"
    static let niiServiceSetup = "Setup:/Network/Service/%@"
    static let niiPPPSetup = "Setup:/Network/Service/.*/PPP"
    
    static let niiInterfaceNameKey = "InterfaceName"
    static let niiServiceKey = "Service"
    static let niiUserDefinedNameKey = "UserDefinedName"
    
    static let niiService = "Service"
    static let niiSessionName = "VPNLookup"
    
    // MARK: Risks
    static let riskLocationServicesEnabled = "Location services are enabled"
    static let riskDnsLeakDetected = "DNS leak detected"
    static let riskWebRtcLeakDetected = "Potential WebRTC leak detected"
    
    // MARK: Shell commands
    static let shCommandEnableNetworkIterface = "networksetup -setairportpower %1$@ on"
    static let shCommandDisableNetworkIterface = "networksetup -setairportpower %1$@ off"
    static let shCommandLoadLaunchAgent = "launchctl load %1$@%2$@"
    static let shCommandEnableLaunchAgent = "launchctl enable %1$@"
    static let shCommandRemoveLaunchAgent = "launchctl remove %1$@"
    static let shCommandToggleLocationServices = "defaults -currentHost write '/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd' LocationServicesEnabled -bool %1$@"
    static let shCommandReboot = "reboot"
    static let shDnsCommand = "scutil --dns"
    
    // MARK: scutil
    static let scutilScopedQueriesHeader = "DNS configuration (for scoped queries)"
    static let scutilResolverPrefix = "resolver #"
    static let scutilNameserverPrefix = "nameserver["
    static let scutilIfIndexPrefix = "if_index"
    static let scutilDomainPrefix = "domain"
    
    // MARK: WebRTC
    static let firefoxProfilesPath = "Application Support/Firefox/Profiles"
    static let firefoxPrefsFile = "/prefs.js"
    static let firefoxWebRtcDisabledEntry = "user_pref(\"media.peerconnection.enabled\", false)"
    static let chromiumWebRtcKey = "webrtc"
    static let chromiumIpHandlingKey = "ip_handling_policy"
    static let chromiumProfileDefault = "Default"
    static let chromiumProfile = "Profile "
    static let chromiumSafePolicies: Set<String> = [
        "disable_non_proxied_udp",
        "default_public_interface_only"
    ]
    
    // MARK: Warnings
    static let warningDnsLeakDoubleCheck = "Always double-check at https://dnsleaktest.com."
    static let warningWebRtcLeakDoubleCheck = "Always double-check at https://browserleaks.com/webrtc."
    
    // MARK: System settings paths
    static let sspLocationServices = "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"
    
    // MARK: Error messages
    static let errorNoActiveIpApiFound = "Unable to fetch IP address. Try to add a new IP API in Settings or check your DNS availability"
    static let errorWhenCallingIpAddressApi = "Error when called IP address API '%1$@': '%2$@', API marked as inactive and will be skipped until next application run"
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
    static let dialogHeaderCloseApp = "Quit application?"
    static let dialogBodyCloseApp = "Are you sure you want to quit?"
    
    // MARK: Log messages
    static let logMonitoringHasBeenEnabled = "Monitoring enabled"
    static let logMonitoringHasBeenDisabled = "Monitoring disabled"
    static let logDnsLeak = "[DNS LEAK CHECKS] "
    static let logWebRtcLeak = "[WebRTC LEAK CHECKS] "
    static let logPublicIp = "Public IP is %1$@ (location: %2$@, fetched from API: %3$@)"
    static let logPublicIpHasBeenUpdated = "Public IP has been updated to %1$@"
    static let logPublicIpHasBeenUpdatedWithNotFromWhitelist = "Public IP address has been changed to %1$@ which is not from allowed IPs, network disabled"
    static let logNetworkInterfaceHasBeenEnabled = "Network interface '%1$@' has been enabled"
    static let logNetworkInterfaceHasBeenDisabled = "Network interface '%1$@' has been disabled"
    static let logCannotEnableNetworkInterface = "Cannot enable network interface '%1$@'"
    static let logCannotDisableNetworkInterface = "Cannot disable network interface '%1$@'"
    static let logLaunchAgentAdded = "Launch agent added, the application will be always running"
    static let logLaunchAgentRemoved = "Launch agent removed, the application won't be always running"
    static let logLocationServicesHaveBeenToggled = "Location services have been %1$@, needs to restart to take effect"
    static let logRebooting = "Rebooting..."
    static let logProcessTerminated = "%1$@ has been closed"
    static let logPreventComputerSleepEnabled = "Preventing the computer from going to sleep is enabled"
    static let logPreventComputerSleepDisabled = "Preventing the computer from going to sleep is disabled"
    static let logDnsMonitoringStarted = "\(logDnsLeak)Monitoring enabled (interval: %1$ds)"
    static let logDnsMonitoringStopped = "\(logDnsLeak)Monitoring disabled"
    static let logDnsCheckInitiated = "\(logDnsLeak)Leak check initiated"
    static let logDnsCheckFailed = "\(logDnsLeak)Check failed: %1$@"
    static let logDnsNoResolversFound = "\(logDnsLeak)Check inconclusive: no resolvers found in scutil output"
    static let logDnsNoVpnDetected = "\(logDnsLeak)No VPN tunnel detected, direct connection in use"
    static let logDnsResolverEntry = "\(logDnsLeak)DNS resolver #%1$d | interface: %2$@ | nameservers: [%3$@]%4$@%5$@"
    static let logDnsLeakDetected = "\(logDnsLeak)⚠️ LEAK DETECTED — %1$d resolver(s) active outside VPN tunnel: %2$@"
    static let logDnsCheckPassed = "\(logDnsLeak)Check passed — all resolvers are tunnel-bound (%1$@)"
    static let logNetworkInterfaceDetails = "interface '%1$@' → [%2$@]"
    static let logLeakFlag = " ⚠️ LEAK"
    static let logDomainSuffix = " | domain: %1$@"
    static let logUnboundInterface = "unbound (system-wide)"
    static let logSystemWide = "system-wide"
    static let logNoSpecificInterface = "no specific interface"
    static let logMaxRetriesExceeded = "Max retries exceeded"
    static let logWebRtcMonitoringStarted = "\(logWebRtcLeak)Monitoring enabled (interval: %1$ds)"
    static let logWebRtcMonitoringStopped = "\(logWebRtcLeak)Monitoring disabled"
    static let chromiumPrefsFile = "Preferences"
    static let logWebRtcBusinessAppWarning = "\(logWebRtcLeak)%1$@ is running. Desktop version has its own WebRTC stack which cannot be adjusted. Use the web version instead."
    static let logWebRtcSafariWarning = "\(logWebRtcLeak)%1$@ is running. Safari's WebRTC settings are protected by macOS SIP and cannot be verified. Go to Develop → Experimental Features and disable Legacy WebRTC API to reduce leak risk. If you did that, this warning can be ignored."
    static let logWebRtcPrefsUnavailable = "\(logWebRtcLeak)%1$@: settings could not be read — assuming unprotected"
    static let logWebRtcNoPolicy = "\(logWebRtcLeak)%1$@ profile '%2$@': no system-level WebRTC policy found. If you use a WebRTC protection extension, this warning can be ignored."
    static let logWebRtcChromiumPolicy = "\(logWebRtcLeak)%1$@ profile '%2$@': WebRTC policy is '%3$@'"
    static let logWebRtcFirefoxProfile  = "\(logWebRtcLeak)Firefox profile '%1$@': WebRTC is %2$@"
    static let logFirefoxProfileProtected = "protected"
    static let logFirefoxProfileUnprotected = "unprotected — consider setting media.peerconnection.enabled to false in about:config"
    
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
    static let hintExtendedProtection = "Disable the network when monitoring is enabled, if there is no reliable information about the current IP address. Also close all running monitored applications, if any."
    static let hintAutoCloseApps = "Force close applications when monitoring is enabled and current IP address is not secure. The confirmation dialog option when closing applications will be ignored."
    static let hintCloseApplicationConfirmation = "Confirmation dialog when closing applications. This option is ignored in higher protection mode."
    static let hintPickyMode = "Use extended information about current IP address, such as country. Does not allow the use of an IP address as an allowed one if there is no reliable information about it."
    static let hintPeriodicIpCheck = "Check the public IP address periodically when monitoring is enabled at the interval specified below."
    static let hintPeriodicDnsLeakCheck = "Check DNS leak periodically when monitoring is enabled at the interval specified below."
    static let hintPeriodicWebRtcLeakCheck = "Check WebRTC leak periodically when monitoring is enabled at the interval specified below."
    static let hintInterval = "\(minTimeIntervalToCheck)..\(maxTimeIntervalToCheck)"
    static let hintMenuBarAdjustment = "Drag menu bar item icons between the sections below to arrange item as you want."
    static let hintAllowedIps = "Add an allowed IP address with desired security type.\nRight click on the address to display the context menu."
    static let hintIpApis = "Add an API that returns the public IP address in plain text\nRight click on the API to display the context menu\nIf API marked green, it works properly and in use."
    static let hintCloseApps = "Add the application you want to close automatically or manually\nRight click on the application to display the context menu"
    static let hintIpInfoApi = "The IP info API is needed to get advanced information about a public IP address, such as its location. This allows you to display the country flag in the macOS menu bar, as well as show the address on a map. Typically, data from such APIs is in JSON format. Here, you can assign an API address and map the JSON data values to application values."
    static let hintNotSet = "Not set yet"
    static let hintJsonKey = "JSON data key"
    static let hintNoLogEntries = "No log entries"
    static let hintLeaks = "This app can monitor your device for potential DNS and WebRTC privacy leaks and notify when a risk is detected. It does NOT prevent leaks. Detection has limitations: some leak vectors, such as browser extensions overriding WebRTC settings or system-level DNS changes, may not be visible to this app."
    static let hintPrivacyProtection = "Only you are responsible for verifying your privacy protection!"
    static let hintNetworkDetails = "Provides extended network details. Optional."
    static let hintPermissions = "Manage application permissions here. Your data is never shared with third parties, including the developer."
    
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
    static let defaultShownMenuBarItems = [
        mbItemKeyShield,
        mbItemKeyMonitoringStatus
    ]
    
    static let defaultHiddenMenuBarItems = [
        mbItemKeyIpAddress,
        mbItemKeyCountryFlag,
        mbItemKeyCountryCode,
        mbItemKeyVpn,
        mbItemKeyLeak,
        mbItemKeyBullet,
        mbItemKeySeparatorBullet,
        mbItemKeySeparatorPipe,
        mbItemKeySeparatorLeftBracket,
        mbItemKeySeparatorRightBracket
    ]
    
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
        "https://api.ip.lk/",
        "https://realip.cc/simple",
        "https://cdid.c-ctrip.com/model-poc2/h",
        "https://ipv4.gdt.qq.com/get_client_ip",
        "https://ifconfig.es/",
        "https://eth0.me",
        "http://ipaddr.site",
        "https://ipaddress.sh",
        "https://wgetip.com",
        "https://ip.tyk.nu",
        "https://curlmyip.net",
        "https://ipcalf.com",
        "https://getip.cc"
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
    
    static let vpnInterfacePrefixes = [
        "tap", 
        "tun",
        "ppp",
        "ipsec",
        "utun"
    ]
    
    static let physicalInterfacePrefixes = [
        "en",
        "bridge",
        "awdl",
        "llw",
        "anpi"
    ]
    
    static let webRtcMonitoredApps: [MonitoredAppInfo] = [
        .chromium(
            name: "Google Chrome",
            profilesBasePath: "Application Support/Google/Chrome"),
        .chromium(
            name: "Brave",
            profilesBasePath: "Application Support/BraveSoftware/Brave-Browser"),
        .chromium(
            name: "Microsoft Edge",
            profilesBasePath: "Application Support/Microsoft Edge"),
        .chromium(
            name: "Opera",
            profilesBasePath: "Application Support/com.operasoftware.Opera"),
        .firefox(name: "Firefox"),
        .safari(name: "Safari"),
        .businessApp(name: "Slack"),
        .businessApp(name: "Microsoft Teams")
    ]
    
    static let webRtcMonitoredAppNames: Set<String> = Set(webRtcMonitoredApps.map { $0.name.lowercased() })
}
