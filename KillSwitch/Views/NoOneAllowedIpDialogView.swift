//
//  NoOneAllowedIpDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 3.08.2024.
//

import SwiftUI

struct NoOneAllowedIpDialogView : View {
    @EnvironmentObject var appState: AppState
    
    @State private var newIpSafetyType: SafetyType = SafetyType.compete
    @State var isPresented = false
    
    var monitoringService = MonitoringService.shared
    var ipService = IpService.shared
    
    var body: some View {
        EmptyView()
        .frame(width: 0, height: 0)
        .sheet(isPresented: $isPresented, content: {
            VStack(alignment: .center){
                Image(nsImage: NSImage(imageLiteralResourceName: Constants.iconApp))
                    .resizable()
                    .frame(width: 60, height: 60)
                Spacer()
                    .frame(height: 15)
                Text(Constants.dialogHeaderNoOneAllowedIp)
                    .font(.title3)
                    .bold()
                Spacer().frame(height: 10)
                Text(isOnline()
                        ? Constants.dialogBodyNoOneAllowedIpIfOnline
                        : Constants.dialogBodyNoOneAllowedIpIfOffline)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10))
                Spacer().frame(height: 20)
                VStack(alignment: .leading) {
                    RadioButton(
                        id: String(SafetyType.compete.rawValue),
                        label: SafetyType.compete.description,
                        size: 12,
                        color: Color.green,
                        textSize: 11,
                        isMarked: newIpSafetyType == SafetyType.compete,
                        callback: { _ in newIpSafetyType = SafetyType.compete }
                    )
                    RadioButton(
                        id: String(SafetyType.some.rawValue),
                        label: SafetyType.some.description,
                        size: 12,
                        color: Color.yellow,
                        textSize: 11,
                        isMarked: newIpSafetyType == SafetyType.some,
                        callback: { _ in newIpSafetyType = SafetyType.some }
                    )
                }
                .isHidden(hidden: !isOnline(), remove: true)
                HStack {
                    Button(action: primaryButtonClickHandler) {
                        Text(Constants.add)
                            .frame(height: 25)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .background(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(Color.green)
                            )
                    }
                    .buttonStyle(.plain)
                    .isHidden(hidden: !isOnline(), remove: true)
                    Spacer()
                        .frame(width: 20)
                        .isHidden(hidden: !isOnline(), remove: true)
                    Button(action: secondaryButtonClickHandler) {
                        Text(Constants.close)
                            .frame(width: 100, height: 25)
                    }
                }.padding()
            }
            .frame(width: 300)
            .padding()
        })
        .onAppear(perform: {
            AppHelper.setUpView(
                viewName: Constants.windowIdEnableNetworkDialog,
                onTop: true)
            isPresented = true
        })
        .onDisappear(perform: {
            closeDialog()
        })
    }
    
    // MARK: Private function
    private func addAllowedIpAddress(safetyType : SafetyType) {
        ipService.addAllowedIp(
            ip: appState.network.currentIpInfo!.ipAddress,
            ipInfo: appState.network.currentIpInfo,
            safetyType: safetyType)
    }
    
    private func isOnline() -> Bool {
        return appState.network.status == .on
    }
    
    private func primaryButtonClickHandler() {
        addAllowedIpAddress(safetyType: newIpSafetyType)
        monitoringService.startMonitoring()
        closeDialog()
    }
    
    private func secondaryButtonClickHandler() {
        closeDialog()
    }
    
    private func closeDialog() {
        appState.views.isNoOneAllowedIpDialogShown = false
        isPresented = false
        AppHelper.activateView(viewId: Constants.windowIdMain)
    }
}

#Preview {
    NoOneAllowedIpDialogView().environmentObject(AppState())
}
