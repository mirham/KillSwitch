//
//  GeneralSettingsEditView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 18.06.2024.
//

import SwiftUI
import Factory

struct LeaksEditView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.controlActiveState) private var controlActiveState

    @Injected(\.locationService) private var locationService
    @Injected(\.dnsService) private var dnsService
    @Injected(\.webRtcService) private var webRtcService
    
    @State private var dnsLeakCheckInterval = 0
    @State private var webRtcLeakCheckInterval = 0
    @State private var hoveredSetting: SettingType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            infoHeader
            infoPrivacy
            dnsLeakCheckRow
            dnsLeakCheckIntervalRow
                .isHidden(!appState.userData.dnsLeakCheck)
            webRtcLeakCheckRow
            webRtcLeakCheckIntervalRow
                .isHidden(!appState.userData.webRtcLeakCheck)
            Spacer()
        }
        .onAppear {
            dnsLeakCheckInterval = appState.userData.dnsLeakCheckInterval
            webRtcLeakCheckInterval = appState.userData.webRtcLeakCheckInterval
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var infoHeader: some View {
        HStack {
            Image(systemName: Constants.iconInfoFill)
                .asInfoIcon()
            Text(Constants.hintLeaks)
                .padding(.top)
                .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var infoPrivacy: some View {
        Text(Constants.hintPrivacyProtection)
            .foregroundStyle(.red)
            .opacity(0.9)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private var dnsLeakCheckRow: some View {
        settingRow(
            title: Constants.settingsElementPeriodicDnsLeakCheck,
            hint: Constants.hintPeriodicDnsLeakCheck,
            isOn: $appState.userData.dnsLeakCheck,
            settingType: .periodicDnsLeakCheck,
            onEnabled: dnsService.startMonitoringAsync,
            onDisabled: dnsService.stopMonitoringAsync
        )
    }
    
    @ViewBuilder
    private var dnsLeakCheckIntervalRow: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Constants.settingsElementIntervalBegin)
                    .padding(.leading, 45)
                TextField(Constants.hintInterval, value: $dnsLeakCheckInterval, formatter: NumberFormatter())
                    .foregroundColor(isTimeIntervalValid(interval: dnsLeakCheckInterval) ? .primary : .red)
                    .onChange(of: dnsLeakCheckInterval) { _, newValue in
                        if isTimeIntervalValid(interval: newValue) {
                            appState.userData.dnsLeakCheckInterval = newValue
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 59)
                
                Text(Constants.settingsElementIntervalEnd)
            }
            WarningHint(text: Constants.warningDnsLeakDoubleCheck)
        }
    }
    
    @ViewBuilder
    private var webRtcLeakCheckRow: some View {
        settingRow(
            title: Constants.settingsElementPeriodicWebRtcLeakCheck,
            hint: Constants.hintPeriodicWebRtcLeakCheck,
            isOn: $appState.userData.webRtcLeakCheck,
            settingType: .periodicWebRtcLeakCheck,
            onEnabled: webRtcService.startMonitoringAsync,
            onDisabled: webRtcService.startMonitoringAsync
        )
        webRtcMonitoredAppsRow
            .isHidden(!appState.userData.webRtcLeakCheck)
    }
    
    @ViewBuilder
    private var webRtcLeakCheckIntervalRow: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Constants.settingsElementIntervalBegin)
                    .padding(.leading, 45)
                
                TextField(Constants.hintInterval, value: $webRtcLeakCheckInterval, formatter: NumberFormatter())
                    .foregroundColor(isTimeIntervalValid(interval: webRtcLeakCheckInterval) ? .primary : .red)
                    .onChange(of: webRtcLeakCheckInterval) { _, newValue in
                        if isTimeIntervalValid(interval: newValue) {
                            appState.userData.webRtcLeakCheckInterval = newValue
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 59)
                
                Text(Constants.settingsElementIntervalEnd)
            }
            WarningHint(text: Constants.warningWebRtcLeakDoubleCheck)
        }
    }
    
    @ViewBuilder
    private var webRtcMonitoredAppsRow: some View {
        FlowLayout(spacing: 8) {
            ForEach(appState.userData.webRtcMonitoredApps.indices, id: \.self) { index in
                let app = appState.userData.webRtcMonitoredApps[index]
                AppToggleChip(
                    app: app,
                    isOn: Binding(
                        get: { app.enabled },
                        set: { appState.userData.webRtcMonitoredApps[index].enabled = $0 }
                    )
                )
            }
        }
        .padding(.leading, 30)
        .padding(.trailing, 30)
    }
    
    @ViewBuilder
    private func settingRow(
        title: String,
        hint: String,
        isOn: Binding<Bool>,
        settingType: SettingType,
        onEnabled: (() async -> Void)? = nil,
        onDisabled: (() async -> Void)? = nil
    ) -> some View {
        HStack {
            Toggle(title, isOn: Binding<Bool>(
                get: { isOn.wrappedValue },
                set: { newValue in
                    isOn.wrappedValue = newValue
                    if newValue {
                        Task { await onEnabled?() }
                    } else {
                        Task { await onDisabled?() }
                    }
                }
            ))
            .withSettingToggleStyle()
            Spacer()
            helpIcon(for: hint)
                .onHover { isHovering in
                    hoveredSetting = (isHovering && controlActiveState == .key)
                        ? settingType : nil
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
    private func helpIcon(for hint: String) -> some View {
        Image(systemName: Constants.iconQuestionMark)
            .asHelpIcon()
    }
    
    // MARK: Private functions
    
    private func isTimeIntervalValid(interval: Int) -> Bool {
        interval >= Constants.minTimeIntervalToCheck
        && interval <= Constants.maxTimeIntervalToCheck
    }
    
    // MARK: Inner types
    
    private enum SettingType {
        case periodicDnsLeakCheck
        case periodicWebRtcLeakCheck
    }
    
    struct AppToggleChip: View {
        let app: MonitoredAppInfo
        @Binding var isOn: Bool
        
        var body: some View {
            Toggle(isOn: app.configurable ? $isOn : .constant(isOn)) {
                Text(app.name)
                    .font(.system(size: 11))
                    .foregroundStyle(app.configurable ? .primary : .secondary)
            }
            .toggleStyle(.checkbox)
            .disabled(!app.configurable)
        }
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
    LeaksEditView().environmentObject(AppState())
}
