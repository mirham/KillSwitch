//
//  AddressApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI

struct GeneralSettingsEditView: View {
    private let appManagementService = AppManagementService.shared
    private let monitoringService = MonitoringService.shared
    private let locationService = LocationService.shared
    private let computerManagementService = ComputerManagementService.shared
    
    @State private var isKeepRunningOn = false
    @State private var useHigherProtection = false
    @State private var usePickyMode = false
    @State private var isLocationServicesEnabled = false
    @State private var initInterval: Double = 0
    @State private var interval: Double = 0
    
    @State private var isLocationServicesToggled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack (alignment: .center) {
                Toggle("Keep application running", isOn: .init(
                    get: { isKeepRunningOn },
                    set: { _, _ in if isKeepRunningOn {
                             isKeepRunningOn = !appManagementService.uninstallLaunchAgent()
                             appManagementService.isLaunchAgentInstalled = false
                         }
                         else {
                             isKeepRunningOn = appManagementService.installLaunchAgent()
                             appManagementService.isLaunchAgentInstalled = true
                        }
                    }))
                .toggleStyle(CheckToggleStyle())
                .pointerOnHover()
                .onAppear {
                    let initState  = appManagementService.isLaunchAgentInstalled
                    isKeepRunningOn = initState
                }
                .padding(.leading)
                .padding(.top)
            }
            HStack (alignment: .top) {
                Toggle("Disable location services", isOn: Binding(
                    get: { !isLocationServicesEnabled },
                    set: {
                        isLocationServicesToggled = true
                        if (isLocationServicesEnabled) {
                            locationService.toggleLocationServices(isEnabled: !$0)
                        }
                    }))
                .toggleStyle(CheckToggleStyle())
                .alert(isPresented: $isLocationServicesToggled) {
                    Alert(title: Text(Constants.dialogHeaderLocationServicesToggled),
                          message: Text(Constants.dialogBodyLocationServicesToggled),
                          primaryButton: Alert.Button.default(Text(Constants.dialogButtonRebootNow), action: { computerManagementService.reboot() }),
                          secondaryButton: .default(Text(Constants.dialogButtonLater)))
                }
                .pointerOnHover()
                .padding(.leading)
                .padding(.top)
            }
            HStack {
                Toggle("Higher protection", isOn: Binding(
                    get: { useHigherProtection },
                    set: {
                        useHigherProtection = $0
                        appManagementService.writeSetting(newValue: $0, key: Constants.settingsKeyHigherProtection)
                    }
                ))
                .toggleStyle(CheckToggleStyle())
                .pointerOnHover()
                .onAppear {
                    let initState  = appManagementService.isLaunchAgentInstalled
                    isKeepRunningOn = initState
                }
                .padding(.leading)
                .padding(.top)
            }
            HStack {
                Toggle("Picky mode", isOn: Binding(
                    get: { usePickyMode },
                    set: {
                        usePickyMode = $0
                        appManagementService.writeSetting(newValue: $0, key: Constants.settingsKeyUsePickyMode)
                    }
                ))
                .toggleStyle(CheckToggleStyle())
                .pointerOnHover()
                .onAppear {
                    let initState  = appManagementService.isLaunchAgentInstalled
                    isKeepRunningOn = initState
                }
                .padding(.leading)
                .padding(.top)
            }
            HStack {
                TextField("1..3600", value: $interval, formatter: NumberFormatter())
                    .foregroundColor(checkIfTimeIntervalValid(interval: interval) ? .primary : .red)
                    .onChange(of: interval) {
                        if (checkIfTimeIntervalValid(interval: interval)){
                            appManagementService.writeSetting(newValue: interval, key: Constants.settingsKeyIntervalBetweenChecks)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                Text("second(s) between IP address checks")
            }.padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .onAppear(){
            isLocationServicesEnabled = locationService.isLocationServicesEnabled()
            useHigherProtection = appManagementService.readSetting(key: Constants.settingsKeyHigherProtection) ?? false
            usePickyMode = appManagementService.readSetting(key: Constants.settingsKeyUsePickyMode) ?? true
            initInterval = appManagementService.readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? 10
            interval = initInterval
        }
        .onDisappear() {
            if(initInterval != interval){
                monitoringService.restartMonitoring()
            }
        }
    }
    
    // MARK: Private functions
    
    private func checkIfTimeIntervalValid(interval: Double) -> Bool {
        let result = interval >= Constants.minTimeIntervalToCheck && interval <= Constants.maxTimeIntervalToCheck
        
        return result
    }
    
}

#Preview {
    AddressApisEditView().environmentObject(AddressesService())
}
