//
//  GeneralSettingsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI

struct GeneralSettingsEditView: View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.controlActiveState) var controlActiveState
    
    private let launchAgentService = LaunchAgentService.shared
    private let monitoringService = MonitoringService.shared
    private let locationService = LocationService.shared
    private let computerService = ComputerService.shared
    
    @State private var isKeepRunningOn = false
    @State private var isLocationServicesToggled: Bool = false
    @State private var interval: Double = 0
    
    @State private var showOverKeepApplicationRunning = false
    @State private var showOverDisableLocationServices = false
    @State private var showOverHigherProtection = false
    @State private var showOverPickyMode = false
    @State private var showOverConfirmationApplicationsClose = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Toggle(Constants.settingsElementKeepAppRunning, isOn: .init(
                    get: { isKeepRunningOn },
                    set: { _, _ in if isKeepRunningOn {
                        isKeepRunningOn = !launchAgentService.delete()
                        launchAgentService.isLaunchAgentInstalled = false
                    }
                    else {
                        isKeepRunningOn = launchAgentService.create()
                        launchAgentService.isLaunchAgentInstalled = true
                    }
                    }))
                    .withSettingToggleStyle()
                    .onAppear {
                        let initState = launchAgentService.isLaunchAgentInstalled
                        isKeepRunningOn = initState
                    }
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverKeepApplicationRunning = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverKeepApplicationRunning,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintKeepApplicationRunning) })
            }
            HStack(alignment: .top) {
                Toggle(Constants.settingsElementDisableLocationServices, isOn: Binding(
                    get: { !appState.system.locationServicesEnabled },
                    set: {
                        isLocationServicesToggled = true
                        if appState.system.locationServicesEnabled {
                            locationService.toggleLocationServices(isEnabled: !$0)
                        }
                    }))
                    .withSettingToggleStyle()
                    .alert(isPresented: $isLocationServicesToggled) {
                        Alert(title: Text(Constants.dialogHeaderLocationServicesToggled),
                              message: Text(Constants.dialogBodyLocationServicesToggled),
                              primaryButton: Alert.Button.default(Text(Constants.dialogButtonRebootNow), action: { computerService.reboot() }),
                              secondaryButton: .default(Text(Constants.later)))
                    }
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverDisableLocationServices = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverDisableLocationServices,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintToggleLocationServices) })
            }
            HStack {
                Toggle(Constants.settingsElementHigherProtection, isOn: Binding(
                    get: { appState.userData.useHigherProtection },
                    set: {
                        appState.userData.useHigherProtection = $0
                    }
                ))
                .withSettingToggleStyle()
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverHigherProtection = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverHigherProtection,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintHigherProtection) })
            }
            HStack {
                Toggle(Constants.settingsElementConfirmationToCloseApps, isOn: Binding(
                    get: { appState.userData.appsCloseConfirmation },
                    set: {
                        appState.userData.appsCloseConfirmation = $0
                    }
                ))
                .withSettingToggleStyle()
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverConfirmationApplicationsClose = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverConfirmationApplicationsClose,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintCloseApplicationConfirmation) })
            }
            HStack {
                Toggle(Constants.settingsElementPickyMode, isOn: Binding(
                    get: { appState.userData.pickyMode },
                    set: {
                        appState.userData.pickyMode = $0
                    }
                ))
                .withSettingToggleStyle()
                Spacer()
                Image(systemName: Constants.iconQuestionMark)
                    .asHelpIcon()
                    .onHover(perform: { hovering in
                        showOverPickyMode = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverPickyMode,
                             arrowEdge: .trailing,
                             content: { renderHelpHint(hint: Constants.hintPickyMode) })
            }
            HStack {
                TextField(Constants.hintInterval, value: $interval, formatter: NumberFormatter())
                    .foregroundColor(checkIfTimeIntervalValid(interval: interval) ? .primary : .red)
                    .onChange(of: interval) {
                        if checkIfTimeIntervalValid(interval: interval) {
                            appState.userData.intervalBetweenChecks = interval
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                Text(Constants.settingsElementInterval)
            }.padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .onAppear {
            interval = appState.userData.intervalBetweenChecks
        }
        .onDisappear {
            if appState.userData.intervalBetweenChecksChanged {
                appState.userData.intervalBetweenChecksChanged = false
                monitoringService.restartMonitoring()
            }
        }
    }
    
    // MARK: Private functions
    
    private func checkIfTimeIntervalValid(interval: Double) -> Bool {
        let result = interval >= Constants.minTimeIntervalToCheck && interval <= Constants.maxTimeIntervalToCheck
        
        return result
    }
    
    private func renderHelpHint(hint: String) -> some View {
        let result = Text(hint)
            .frame(width: 200)
            .padding()
        
        return result
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
            .foregroundColor(/*@START_MENU_TOKEN@*/ .blue/*@END_MENU_TOKEN@*/)
            .padding(.top)
            .padding(.trailing)
    }
}

#Preview {
    GeneralSettingsEditView().environmentObject(AppState())
}
