<p align="center">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/AppLogo.png" width="370"/>
</p>

<p align="center" style="text-align: center">
  <a href="https://github.com/mirham/KillSwitch/tags" rel="nofollow">
    <img alt="GitHub tag (latest SemVer pre-release)" src="https://img.shields.io/github/v/tag/mirham/KillSwitch?include_prereleases&label=version"/>
  </a>
  <a href="https://github.com/mirham/KillSwitch/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/mirham/KillSwitch"/>
  </a>
  <img alt="macOS" src="https://img.shields.io/badge/macOS-blue?logo=apple"/>
  <img alt="Swift" src="https://img.shields.io/badge/Swift-grey?logo=swift"/>
  <img alt="Pet project" src="https://img.shields.io/badge/Pet project-purple?logo=github"/>
</p>

## Introduction
MirHam KillSwich is a macOS menu bar app that gives you greater control over your internet connection and helps protect your privacy.

When your public IP address changes to one that isn't on your allowed list, the app automatically disables all network interfaces — giving you time to assess the situation and restore a safe connection before resuming work.

This is especially useful for VPN users, particularly those using modern protocols such as VLESS, Trojan, Shadowsocks, and others.

## Features
- Simple and intuitive to use
- Highly customizable: menu bar items, APIs, and security levels
- Configurable allowed IP address list with security levels
- Automatically disables network interfaces when an unsafe IP address is detected
- Periodic public IP address checks at configurable intervals
- DNS and WebRTC leak detection and monitoring (see limitations below)
- Automatically or manually quit applications when a security risk is detected
- Prevents the computer from sleeping while monitoring is active (may not work without a power adapter on some Macs)
- Built-in log viewer, detailed logs
- Launch agent support — runs automatically after system startup

## Compatibility

This application is compatible with macOS 15.0 and above. All versions below 3.0 are compatible with macOS 14.0. Version [2.6](https://github.com/mirham/KillSwitch/releases/tag/2.6) is the last compatible version for macOS 14.0 and will only be upgraded by request.

## Installation

Download the DMG installer from the [releases](https://github.com/mirham/KillSwitch/releases), mount it, and drag and drop the application to the Applications folder. That's it! However, you will need to allow launching applications from unidentified developers to start the application, as I don't have an Apple developer license.

## Screenshots

### Menu bar
<p align="left">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/MenuBarView.png">
</p>

### Main window
<p align="left">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/MainView.png" width="900">
</p>

### Settings
<p align="left">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView1.png" width="600">
  <br/>
  <br/>
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView2.png" width="600">
  <br/>
  <br/>
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView3.png" width="600">
  <br/>
  <br/>
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView4.png" width="600">
  <br/>
  <br/>
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView5.png" width="600">
  <br/>
  <br/>
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView6.png" width="600">
  <br/>
  <br/>
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView7.png" width="600">
  <br/>
  <br/>
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView8.png" width="600">
</p>

## DNS and WebRTC Leak Detection — Limitations
Because I don't have an Apple Developer license ($99/year), I cannot create a Network Extension, which would be the ideal solution for both accurate leak detection (including STUN monitoring) and pausing network traffic without disabling interfaces entirely. I plan to build this in the future, but that version will likely not be free.

In the meantime, this app uses methods that require fewer privileges. They are less precise, but can still catch most common leaks. Always verify your privacy using these tools:

- DNS leaks: https://www.dnsleaktest.com
- WebRTC leaks: https://browserleaks.com/webrtc

For WebRTC leaks in particular, make sure to test every app you use for audio or video calls — browsers, Electron-based apps, and so on — not just one.

If you're seeing unwanted leak warnings in the log, you can disable the checks or exclude specific apps to reduce noise. Note that Slack and Microsoft Teams cannot be excluded from WebRTC leak checks — these apps are among the highest-risk for WebRTC leaks, as corporate administrators may be able to detect your real IP address through them. For these apps, I recommend using their web versions instead, with a WebRTC-blocking browser extension or the appropriate browser settings configured.

## Troubleshooting
### The app doesn't start after installation
> [!TIP]
> The app lives in the menu bar by default. On the very first run it should look like <img src="https://github.com/mirham/KillSwitch/blob/main/Images/DefaultMenuBarView.png"> in the menu bar. If you use a menu bar manager such as Bartender or Ice, it may have hidden the app's menu bar item — check there first before troubleshooting further.

This happens because macOS quarantines apps that aren't downloaded from the App Store or signed by a verified developer. On the first launch, macOS may silently block the app even after you click "Open Anyway" in Security & Privacy settings.

**Fix:**

Open Terminal and run:

```bash
xattr -rd com.apple.quarantine /Applications/KillSwitch.app
```

Or drag the app onto the Terminal window after typing `xattr -rd com.apple.quarantine ` (note the space at the end), then press Enter.

After that, the app will launch normally on every subsequent run.

**Step by step:**
1. Copy the app to your Applications folder
2. Try to open it — if blocked, go to **System Settings → Privacy & Security** and click **Open Anyway**
3. If the app still doesn't start, open Terminal and run the command above
4. Launch the app again

### Where can I find a public IP API?
You can find free IP APIs that return plain text and require no API key by searching online for "free IP API plain text no API key." Many are available, though not all may work in your country. Alternatively, you can create and deploy your own — it's not complicated. The only requirement is that it returns the IP address as plain text, with no additional data.

### Where can I find a public IP info API?
This is more complex. Search online for "free IP geolocation API no API key." Many free services exist, but most require registration and an API key. You are welcome to use those if you wish.

Two free services that work without an API key:
- `http://ip-api.com/json/%IP%` — used by default
- `https://free.freeipapi.com/api/json/%IP%` — available but less accurate

`%IP%` is a placeholder for your public IP address.

Field mapping for the second service:
- Country code → `countryCode`
- Country name → `countryName`
- IP address → `ipAddress`

### The app displays "Fetching IP..." for a long time
This happens when some IP APIs are unreachable from your current location. The app skips unresponsive APIs, but this takes time. After updating the public IP, the app will attempt to use them again.

To fix this, open each API URL in your browser. If an API no longer returns an IP address quickly as plain text, remove it from the app. You can also search for and add new working APIs — the more the better. Having **at least 10 active APIs** is recommended to ensure reliable performance.

### The app displays "No active IP API"
This means no IP API is currently reachable and the app cannot determine your public IP address. At least one working API is required for the app to function, but having **at least 10** is strongly recommended to avoid this issue.

You can check the status of each API under `Settings` → `IP APIs`. This message typically indicates a network problem, such as a connectivity or DNS issue. Try restarting the app to reactivate the APIs. If the problem persists, add as many working APIs as possible, as described above.

### I'm seeing frequent leak warnings in the log
If DNS or WebRTC leak warnings appear frequently and you consider them false positives, you can disable the relevant checks entirely or exclude specific applications in Settings.

### Why can't I exclude Slack or Microsoft Teams from WebRTC monitoring?
Slack and Microsoft Teams use their own built-in WebRTC stack that cannot be inspected or controlled by this app. Because of this, they cannot be excluded from WebRTC leak checks. More importantly, these apps are among the highest-risk for WebRTC leaks — corporate administrators may be able to detect your real IP address through them. For these apps, it is strongly recommended to use their web versions instead, with a WebRTC-blocking browser extension or the appropriate browser settings configured.

## Improvement
> [!TIP]
> If you have any ideas, thoughts, or concerns, don't hesitate to contact me. I'm happy to help and improve the application.

## Disclaimer
> [!WARNING]
> I'm not a professional Swift developer (though I am a professional .NET developer). All my macOS apps are made for personal use by myself and my family simply because I have the skills to create them (and for fun, of course 😊). If my application has caused any harm, I apologize for that, but please be aware that you use it at your own risk.
