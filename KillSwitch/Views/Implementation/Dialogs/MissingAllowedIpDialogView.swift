//
//  MissingAllowedIpDialogView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 3.08.2024.
//

import SwiftUI
import Factory

struct MissingAllowedIpDialogView: View {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.monitoringService) private var monitoringService
    @Injected(\.ipService) private var ipService
    
    @State private var selectedSecurityType: SecurityType = .compete
    @State private var isDialogPresented = false
    
    var body: some View {
        EmptyView()
            .frame(width: 0, height: 0)
            .sheet(isPresented: $isDialogPresented) {
                dialogContent
            }
            .onAppear(perform: openDialog)
            .onDisappear(perform: closeDialog)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var dialogContent: some View {
        VStack(alignment: .center) {
            appIcon
            Spacer().frame(height: 15)
            Text(Constants.dialogHeaderNoOneAllowedIp)
                .font(.title3)
                .bold()
            Spacer().frame(height: 10)
            messageText
            Spacer().frame(height: 20)
            securityTypeRadios
                .isHidden(!isOnline)
            HStack {
                addButton
                    .isHidden(!isOnline)
                Spacer()
                    .frame(width: 20)
                    .isHidden(!isOnline)
                closeButton
            }
            .padding()
        }
        .frame(width: 300)
        .padding()
        .safeGlassEffect()
    }
    
    @ViewBuilder
    private var appIcon: some View {
        Image(nsImage: NSImage(imageLiteralResourceName: Constants.iconApp))
            .resizable()
            .frame(width: 60, height: 60)
    }
    
    @ViewBuilder
    private var messageText: some View {
        let message = isOnline
            ? Constants.dialogBodyNoOneAllowedIpIfOnline
            : Constants.dialogBodyNoOneAllowedIpIfOffline
        
        Text(message)
            .multilineTextAlignment(.center)
            .font(.system(size: 10))
            .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var securityTypeRadios: some View {
        VStack(alignment: .leading) {
            RadioButton(
                id: String(SecurityType.compete.rawValue),
                label: SecurityType.compete.description,
                size: 12,
                color: .green,
                textSize: 11,
                isMarked: selectedSecurityType == .compete,
                callback: { _ in selectedSecurityType = .compete }
            )
            RadioButton(
                id: String(SecurityType.some.rawValue),
                label: SecurityType.some.description,
                size: 12,
                color: .yellow,
                textSize: 11,
                isMarked: selectedSecurityType == .some,
                callback: { _ in selectedSecurityType = .some }
            )
        }
    }
    
    @ViewBuilder
    private var addButton: some View {
        Button(action: handleAddButtonClick) {
            Text(Constants.add)
                .frame(height: 25)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.green)
                )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var closeButton: some View {
        Button(action: handleCloseButtonClick) {
            Text(Constants.close)
                .frame(width: 100, height: 25)
        }
    }
    
    // MARK: Private functions
    
    private var isOnline: Bool {
        appState.network.status == .on
    }
    
    private func addAllowedIpAddress(securityType: SecurityType) {
        guard let publicIp = appState.network.publicIp
        else { return }
        
        let ip = IpInfo(
            ipAddress: publicIp.ipAddress,
            ipAddressInfo: publicIp,
            securityType: securityType
        )
        
        ipService.addAllowedPublicIp(publicIp: ip)
    }
    
    private func handleAddButtonClick() {
        addAllowedIpAddress(securityType: selectedSecurityType)
        monitoringService.startMonitoring()
        closeDialog()
    }
    
    private func handleCloseButtonClick() {
        closeDialog()
    }
    
    private func openDialog() {
        appState.views.shownWindows.append(Constants.windowIdNoOneAllowedIpDialog)
        
        AppHelper.setUpView(
            viewName: Constants.windowIdEnableNetworkDialog,
            onTop: true
        )
        
        isDialogPresented = true
    }
    
    private func closeDialog() {
        appState.views.shownWindows.removeAll { $0 == Constants.windowIdNoOneAllowedIpDialog }
        isDialogPresented = false
        AppHelper.activateView(viewId: Constants.windowIdMain)
    }
}

#Preview {
    MissingAllowedIpDialogView().environmentObject(AppState())
}
