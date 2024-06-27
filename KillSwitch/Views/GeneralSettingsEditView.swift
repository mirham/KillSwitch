//
//  AddressApisEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI

struct GeneralSettingsEditView : View, Settable {
    private let appManagementService = AppManagementService.shared
    private let monitoringService = MonitoringService.shared
    private let locationService = LocationService.shared
    private let computerManagementService = ComputerManagementService.shared
    
    @Environment(\.controlActiveState) var controlActiveState
    
    @State private var isKeepRunningOn = false
    @State private var useHigherProtection = false
    @State private var usePickyMode = false
    @State private var isLocationServicesEnabled = false
    @State private var confirmationApplcationsClose = false
    @State private var initInterval: Double = 0
    @State private var interval: Double = 0
    
    @State private var isLocationServicesToggled: Bool = false
    
    @State private var showOverKeepApplicationRunning = false
    @State private var showOverDisableLocationServices = false
    @State private var showOverHigherProtection = false
    @State private var showOverPickyMode = false
    @State private var showOverConfirmationApplicationsClose = false
    
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
                Spacer()
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                    .padding(.trailing)
                    .onHover(perform: { hovering in
                        showOverKeepApplicationRunning = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverKeepApplicationRunning, 
                             arrowEdge: .trailing,
                             content: {
                        Text("The application will be opened after the system starts or if it was closed.")
                            .frame(width: 200)
                            .padding()
                    })
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
                Spacer()
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                    .padding(.trailing)
                    .onHover(perform: { hovering in
                        showOverDisableLocationServices = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverDisableLocationServices, 
                             arrowEdge: .trailing,
                             content: {
                        Text("Toggle location services after restart. If the required state is critical, this can be done manually in Settings → Privacy & Security → Location Services without restarting.")
                            .frame(width: 200)
                            .padding()
                    })
            }
            HStack {
                Toggle("Higher protection", isOn: Binding(
                    get: { useHigherProtection },
                    set: {
                        useHigherProtection = $0
                        writeSetting(newValue: $0, key: Constants.settingsKeyHigherProtection)
                    }
                ))
                .toggleStyle(CheckToggleStyle())
                .pointerOnHover()
                .padding(.leading)
                .padding(.top)
                Spacer()
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                    .padding(.trailing)
                    .onHover(perform: { hovering in
                        showOverHigherProtection = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverHigherProtection, 
                             arrowEdge: .trailing,
                             content: {
                        Text("Disable the network when monitoring is enabled, if there is no reliable information about the current IP address. Also closes all running monitored applications, if any.")
                            .frame(width: 200)
                            .padding()
                    })
            }
            HStack {
                Toggle("Confirmation to close applications", isOn: Binding(
                    get: { confirmationApplcationsClose },
                    set: {
                        confirmationApplcationsClose = $0
                        writeSetting(newValue: $0, key: Constants.settingsKeyConfirmationApplicationsClose)
                    }
                ))
                .toggleStyle(CheckToggleStyle())
                .pointerOnHover()
                .padding(.leading)
                .padding(.top)
                Spacer()
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                    .padding(.trailing)
                    .onHover(perform: { hovering in
                        showOverConfirmationApplicationsClose = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverConfirmationApplicationsClose,
                             arrowEdge: .trailing,
                             content: {
                        Text("Confirmation dialog when closing applications. This option is ignored in higher protection mode.")
                            .frame(width: 200)
                            .padding()
                    })
            }
            HStack {
                Toggle("Picky mode", isOn: Binding(
                    get: { usePickyMode },
                    set: {
                        usePickyMode = $0
                        writeSetting(newValue: $0, key: Constants.settingsKeyUsePickyMode)
                    }
                ))
                .toggleStyle(CheckToggleStyle())
                .pointerOnHover()
                .padding(.leading)
                .padding(.top)
                Spacer()
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                    .padding(.trailing)
                    .onHover(perform: { hovering in
                        showOverPickyMode = hovering && controlActiveState == .key
                    })
                    .popover(isPresented: $showOverPickyMode, 
                             arrowEdge: .trailing,
                             content: {
                        Text("Use extended information about current IP address, such as country. Does not allow the use of an IP address as an allowed one if there is no reliable information about it.")
                            .frame(width: 200)
                            .padding()
                    })
            }
            HStack {
                TextField("1..3600", value: $interval, formatter: NumberFormatter())
                    .foregroundColor(checkIfTimeIntervalValid(interval: interval) ? .primary : .red)
                    .onChange(of: interval) {
                        if (checkIfTimeIntervalValid(interval: interval)){
                            writeSetting(newValue: interval, key: Constants.settingsKeyIntervalBetweenChecks)
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
            useHigherProtection = readSetting(key: Constants.settingsKeyHigherProtection) ?? false
            usePickyMode = readSetting(key: Constants.settingsKeyUsePickyMode) ?? true
            confirmationApplcationsClose = readSetting(key: Constants.settingsKeyConfirmationApplicationsClose) ?? true
            initInterval = readSetting(key: Constants.settingsKeyIntervalBetweenChecks) ?? 10
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
