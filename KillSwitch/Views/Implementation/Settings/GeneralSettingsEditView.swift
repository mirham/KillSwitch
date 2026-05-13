//
//  GeneralSettingsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI
import Factory

struct GeneralSettingsEditView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.controlActiveState) private var controlActiveState
    
    @Injected(\.launchAgentService) private var launchAgentService
    @Injected(\.locationService) private var locationService
    @Injected(\.computerService) private var computerService
    
    @State private var isKeepRunningOn = false
    @State private var isLocationServicesToggled = false
    @State private var interval = 0
    @State private var hoveredSetting: SettingType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            keepApplicationRunningRow
            onTopOfAllWindowsRow
            disableLocationServicesRow
            preventComputerSleepRow
            higherProtectionRow
            autoCloseAppsRow
            confirmationToCloseAppsRow
            pickyModeRow
            periodicIpCheckRow
            periodicIpCheckIntervalRow
                .isHidden(!appState.userData.periodicIpCheck)
            
            Spacer()
        }
        .onAppear {
            isKeepRunningOn = launchAgentService.isInstalled
            interval = appState.userData.intervalBetweenChecks
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var keepApplicationRunningRow: some View {
        settingRow(
            title: Constants.settingsElementKeepAppRunning,
            hint: Constants.hintKeepApplicationRunning,
            isOn: Binding(
                get: { isKeepRunningOn },
                set: { newValue in
                    if newValue {
                        isKeepRunningOn = launchAgentService.create()
                        launchAgentService.setState(isInstalled: true)
                    } else {
                        isKeepRunningOn = !launchAgentService.delete()
                        launchAgentService.setState(isInstalled: false)
                    }
                }
            ),
            settingType: .keepApplicationRunning
        )
    }
    
    @ViewBuilder
    private var onTopOfAllWindowsRow: some View {
        settingRow(
            title: Constants.settingsElementOnTopOfAllWindows,
            hint: Constants.hintOnTopOfAllWindows,
            isOn: $appState.userData.onTopOfAllWindows,
            settingType: .onTopOfAllWindows
        )
    }
    
    @ViewBuilder
    private var disableLocationServicesRow: some View {
        settingRow(
            title: Constants.settingsElementDisableLocationServices,
            hint: Constants.hintToggleLocationServices,
            isOn: Binding(
                get: { !appState.system.locationServicesEnabled },
                set: { newValue in
                    isLocationServicesToggled = true
                    if appState.system.locationServicesEnabled {
                        locationService.toggleLocationServices(isEnabled: !newValue)
                    }
                }
            ),
            settingType: .disableLocationServices
        )
        .alert(isPresented: $isLocationServicesToggled) {
            Alert(
                title: Text(Constants.dialogHeaderLocationServicesToggled),
                message: Text(Constants.dialogBodyLocationServicesToggled),
                primaryButton: .default(
                    Text(Constants.dialogButtonRebootNow),
                    action: { computerService.reboot() }),
                secondaryButton: .default(Text(Constants.later))
            )
        }
    }
    
    @ViewBuilder
    private var preventComputerSleepRow: some View {
        settingRow(
            title: Constants.settingsElementPreventComputerSleep,
            hint: Constants.hintPreventComputerSleep,
            isOn: $appState.userData.preventComputerSleep,
            settingType: .preventComputerSleep
        )
    }
    
    @ViewBuilder
    private var higherProtectionRow: some View {
        settingRow(
            title: Constants.settingsElementExtendedProtection,
            hint: Constants.hintExtendedProtection,
            isOn: $appState.userData.useExtendedProtection,
            settingType: .higherProtection
        )
    }
    
    @ViewBuilder
    private var autoCloseAppsRow: some View {
        settingRow(
            title: Constants.settingsElementAutoCloseApps,
            hint: Constants.hintAutoCloseApps,
            isOn: $appState.userData.autoCloseApps,
            settingType: .autoCloseApps
        )
    }
    
    @ViewBuilder
    private var confirmationToCloseAppsRow: some View {
        settingRow(
            title: Constants.settingsElementConfirmationToCloseApps,
            hint: Constants.hintCloseApplicationConfirmation,
            isOn: $appState.userData.appsCloseConfirmation,
            settingType: .confirmationToCloseApps
        )
    }
    
    @ViewBuilder
    private var pickyModeRow: some View {
        settingRow(
            title: Constants.settingsElementPickyMode,
            hint: Constants.hintPickyMode,
            isOn: $appState.userData.pickyMode,
            settingType: .pickyMode
        )
    }
    
    @ViewBuilder
    private var periodicIpCheckRow: some View {
        settingRow(
            title: Constants.settingsElementPeriodicIpCheck,
            hint: Constants.hintPeriodicIpCheck,
            isOn: $appState.userData.periodicIpCheck,
            settingType: .periodicIpCheck
        )
    }
    
    @ViewBuilder
    private var periodicIpCheckIntervalRow: some View {
        HStack {
            Text(Constants.settingsElementIntervalBegin)
                .padding(.leading, 45)
            
            TextField(Constants.hintInterval, value: $interval, formatter: NumberFormatter())
                .foregroundColor(isTimeIntervalValid ? .primary : .red)
                .onChange(of: interval) { _, newValue in
                    if isTimeIntervalValid(interval: newValue) {
                        appState.userData.intervalBetweenChecks = newValue
                    }
                }
                .textFieldStyle(.roundedBorder)
                .frame(width: 59)
            
            Text(Constants.settingsElementIntervalEnd)
        }
    }
    
    @ViewBuilder
    private func settingRow(
        title: String,
        hint: String,
        isOn: Binding<Bool>,
        settingType: SettingType
    ) -> some View {
        HStack {
            Toggle(title, isOn: isOn)
                .withSettingToggleStyle()
            Spacer()
            
            helpIcon(for: hint, settingType: settingType)
                .onHover { isHovering in
                    hoveredSetting = (isHovering && controlActiveState == .key)
                        ? settingType
                        : nil
                }
                .popover(
                    isPresented: .constant(hoveredSetting == settingType),
                    arrowEdge: .trailing
                ) {
                    Text(hint)
                        .frame(width: 200)
                        .padding()
                }
        }
    }
    
    @ViewBuilder
    private func helpIcon(
        for hint: String,
        settingType: SettingType) -> some View {
        Image(systemName: Constants.iconQuestionMark)
            .asHelpIcon()
    }
    
    // MARK: Private functions
    
    private var isTimeIntervalValid: Bool {
        isTimeIntervalValid(interval: interval)
    }
    
    private func isTimeIntervalValid(interval: Int) -> Bool {
        interval >= Constants.minTimeIntervalToCheck && interval <= Constants.maxTimeIntervalToCheck
    }
    
    // MARK: Inner types
    
    private enum SettingType {
        case keepApplicationRunning
        case onTopOfAllWindows
        case disableLocationServices
        case preventComputerSleep
        case higherProtection
        case autoCloseApps
        case confirmationToCloseApps
        case pickyMode
        case periodicIpCheck
    }
}

private extension Toggle {
    func withSettingToggleStyle() -> some View {
        self.toggleStyle(CheckToggleStyle())
            .pointerOnHover()
            .padding(.leading)
            .padding(.top)
    }
}

private extension Image {
    func asHelpIcon() -> some View {
        self.resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(.blue)
            .padding(.top)
            .padding(.trailing)
    }
}

#Preview {
    GeneralSettingsEditView().environmentObject(AppState())
}
