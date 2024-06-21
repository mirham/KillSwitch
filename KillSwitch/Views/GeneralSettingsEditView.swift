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
    
    @State private var isKeepRunningOn = false
    @State private var usePickyMode = false
    @State private var initInterval: Double = 0
    @State private var interval: Double = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack (alignment: .top) {
                Toggle("Keep application running", isOn: .init(
                    get: { isKeepRunningOn },
                    set: { _, _ in if isKeepRunningOn {
                            isKeepRunningOn = !appManagementService.uninstallLaunchAgent()
                         }
                         else {
                            isKeepRunningOn = appManagementService.installLaunchAgent()
                        }
                    }))
                .toggleStyle(CheckToggleStyle())
                .onHover(perform: { hovering in
                    if hovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                })
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
                .onHover(perform: { hovering in
                    if hovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                })
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
                            appManagementService.writeSetting(newValue: interval, key: Constants.settingsIntervalBetweenChecks)
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
            usePickyMode = appManagementService.readSetting(key: Constants.settingsKeyUsePickyMode) ?? false
            initInterval = appManagementService.readSetting(key: Constants.settingsIntervalBetweenChecks) ?? 10
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
