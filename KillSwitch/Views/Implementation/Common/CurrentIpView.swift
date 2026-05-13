//
//  CurrentIpView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 05.06.2024.
//

import SwiftUI
import Factory

struct CurrentIpView: IpAddressContainerView {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    @Injected(\.ipService) private var ipService
    
    var showDetailedIssues: Bool = false
    
    private var ipLabel: String {
        switch appState.network.status {
            case .off: return Constants.offline
            default: return appState.network.isFetchingIp
                ? Constants.fetchingIp
                : appState.network.publicIp?.ipAddress ?? Constants.none
        }
    }
    
    private var ipColor: Color {
        appState.monitoring.isEnabled
        ? securityColor
        : .primary
    }
    
    private var shouldShowSecuritySection: Bool {
        appState.current.securityType != .unknown
        && appState.network.status != .off
    }
    
    private var securityColor: Color {
        getSecurityColor(
            securityType: appState.current.securityType,
            colorScheme: colorScheme)
    }
    
    var body: some View {
        Section {
            VStack(spacing: 2) {
                ipSection
                countrySection
                securitySection
                    .padding(.top, 5)
            }
            .padding(5)
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.08))
            )
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var ipSection: some View {
        if appState.network.status != .off {
            Text(Constants.publicIp)
                .textCase(.uppercase)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        
        Text(ipLabel)
            .textCase(.uppercase)
            .font(.system(size: 20, weight: .semibold, design: .monospaced))
            .foregroundStyle(ipColor)
            .contextMenu { ipContextMenu }
    }
    
    @ViewBuilder
    private var securitySection: some View {
        if shouldShowSecuritySection {
            SecurityBadgeView(
                securityType: appState.current.securityType,
                isHighRisk: appState.current.isHighRisk,
                securityColor: securityColor,
                showDetailedIssues: showDetailedIssues
            )
        }
    }
    
    @ViewBuilder
    private var countrySection: some View {
        if appState.current.isCountryDetected,
           let publicIp = appState.network.publicIp {
            HStack(spacing: 2) {
                let flag = getCountryFlag(countryCode: publicIp.countryCode)
                Image(nsImage: flag)
                    .resizable()
                    .frame(width: flag.size.width, height: flag.size.height)
                    .scaleEffect(0.6)
                Text(publicIp.countryName)
                    .font(.system(size: 11))
            }
            .opacity(0.9)
        }
    }
    
    @ViewBuilder
    private var ipContextMenu: some View {
        if let ipAddress = appState.network.publicIp?.ipAddress {
            Button(Constants.menuItemCopy) {
                AppHelper.copyTextToClipboard(text: ipAddress)
            }
            
            if appState.current.securityType == .unknown {
                Button(Constants.menuItemAddAsAllowedIpWithFullSecurity) {
                    addAllowedIp(securityType: .full)
                }
                Button(Constants.menuItemAddAsAllowedIpWithPartialSecurity) {
                    addAllowedIp(securityType: .partial)
                }
            }
        }
    }
    
    // MARK: Private functions
    
    private func addAllowedIp(securityType: SecurityType) {
        guard let publicIp = appState.network.publicIp
        else { return }
        
        let ip = IpInfo(
            ipAddress: publicIp.ipAddress,
            ipAddressInfo: publicIp,
            securityType: securityType
        )
        
        ipService.addAllowedPublicIp(publicIp: ip)
    }
}

#Preview {
    CurrentIpView().environmentObject(AppState())
}
