//
//  NoOneAllowedIpDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 3.08.2024.
//

import SwiftUI
import Factory

struct NoOneAllowedIpDialogView : View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.monitoringService) private var monitoringService
    @Injected(\.ipService) private var ipService
    
    @State private var newIpSafetyType: SafetyType = SafetyType.compete
    @State var isPresented = false
    
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
                    Button(action: handlePrimaryButtonClick) {
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
                    Button(action: handleSecondaryButtonClick) {
                        Text(Constants.close)
                            .frame(width: 100, height: 25)
                    }
                }.padding()
            }
            .frame(width: 300)
            .padding()
        })
        .onAppear(perform: {
            openDialog()
        })
        .onDisappear(perform: {
            closeDialog()
        })
    }
    
    // MARK: Private functions
    
    private func addAllowedIpAddress(safetyType : SafetyType) {
        let ip = IpInfo(
            ipAddress: appState.network.publicIp!.ipAddress,
            ipAddressInfo: appState.network.publicIp,
            safetyType: safetyType)
        
        self.ipService.addAllowedPublicIp(publicIp: ip)
    }
    
    private func isOnline() -> Bool {
        return appState.network.status == .on
    }
    
    private func handlePrimaryButtonClick() {
        addAllowedIpAddress(safetyType: newIpSafetyType)
        self.monitoringService.startMonitoring()
        closeDialog()
    }
    
    private func handleSecondaryButtonClick() {
        closeDialog()
    }
    
    private func openDialog() {
        appState.views.shownWindows
            .append(Constants.windowIdNoOneAllowedIpDialog)
        
        AppHelper.setUpView(
            viewName: Constants.windowIdEnableNetworkDialog,
            onTop: true)
        
        isPresented = true
    }
    
    private func closeDialog() {
        appState.views.shownWindows
            .removeAll(where: {$0 == Constants.windowIdNoOneAllowedIpDialog})
        
        isPresented = false
        
        AppHelper.activateView(viewId: Constants.windowIdMain)
    }
}

#Preview {
    NoOneAllowedIpDialogView().environmentObject(AppState())
}
