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
MirHam KillSwich is a macOS menu bar application designed to provide additional control over your internet connection. It helps ensure your safety by disabling all physical network interfaces when your public IP address changes to an unsafe one. This allows you time to determine what happened to the connection and restore safe conditions before continuing your work. This application is especially useful for VPN users, particularly those using modern protocols such as VLESS, Trojan, SS, and more.

## Features
- Easy to use
- Adjustable and flexible
- Customizable menu bar items and used APIs
- Operates continuously, even after computer restarts
- Periodic public IP checks at desired intervals
- Automatically or manually close applications
- Manage physical network connections
- Preventing the computer from going to sleep (may not work without a power adapter connected on some Macs)

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
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/MainView.png" width="800">
</p>

### Settings
<p align="left">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView1.png" width="400">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView2.png" width="400">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView3.png" width="400">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView4.png" width="400">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView5.png" width="400">
  <img src="https://github.com/mirham/KillSwitch/blob/main/Images/SettingsView6.png" width="400">
</p>

## Troubleshooting
### Where I can find public IP API?
You can find free IP APIs that return plain text and require no API key by searching online for "Free IP API plain text no API key." While many are available, not all may work in your country. Alternatively, you can create and deploy your own public IP API, it's not very complicated. The main condition is that it must return only the IP address as plain text, without any additional data.
### Where I can find public IP info API?
This is more complex, but you can also search online for "Free IP geolocation API no API key." While many free services exist, most require registration and an API key in the request. However, you are welcome to use them if you wish.

I can recommend two free services:

 - ```http://ip-api.com/json/%IP%``` – This one is used by default.
 - ```https://free.freeipapi.com/api/json/%IP%``` – This one is less accurate.

The mapping for the last service is as follows:

  - City name -> ```cityName```
  - Country code -> ```countryCode```
  - Country name -> ```countryName```
  - IP address -> ```ipAddress```
  - Latitude -> ```latitude```
  - Longitude -> ```longitude```
  - Region name -> ```regionName```
  - Zip code -> leave blank
### The app dispalys "Obtaining IP..." for a long time
This could happen if some public IP APIs are unreachable from your current connection location. The app skips these, but this process takes time. Furthermore, after updating the public IP, the app attempts to use them again. I recommend checking public IP APIs in your browser. If an API no more rapidly return an IP address as plain text, you should remove that API from the app. This will solve the problem. Additionally, you can find new free APIs online, if they work well, feel free to add them to the app.
### The app dispalys "No active IP API"
This means no IP API can be called at this moment, and the application cannot obtain your public IP address. For the app to function normally, at least one IP API must be available and working properly. But it is better to have a lot of them, **at least 10**, to prevent this message from appearing. You can check the status of each IP API under `Settings` -> `IP APIs`. The "No active IP API" message indicates a network problem, such as a connection or DNS issue. Try restarting the application to reactivate the IP APIs. If this doesn't resolve the problem, please find and add working IP APIs, as explained in the previous instructions, as more as possible.

## Improvement
> [!TIP]
> If you have any ideas, thoughts, or concerns, don't hesitate to contact me. I'm happy to help and improve the application.

## Disclaimer
> [!WARNING]
> I'm not a professional Swift developer (though I am a professional .NET developer). All my macOS apps are made for personal use by myself and my family simply because I have the skills to create them (and for fun, of course 😊). If my application has caused any harm, I apologize for that, but please be aware that you use it at your own risk.
