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
    
    @State private var isHoveringRisk = false
    
    var body: some View {
        Section {
            VStack(spacing: 2) {
                ipSection
                countrySection
                safetySection
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
    private var safetySection: some View {
        if shouldShowSafetySection {
            SafetyBadgeView(
                safetyType: appState.current.safetyType,
                isHighRisk: appState.current.isHighRisk,
                safetyColor: safetyColor,
                isRisky: $isHoveringRisk
            )
        }
    }
    
    @ViewBuilder
    private var countrySection: some View {
        if appState.current.isCountryDetected,
           let publicIp = appState.network.publicIp {
            HStack {
                let flag = getCountryFlag(countryCode: publicIp.countryCode)
                Image(nsImage: flag)
                    .resizable()
                    .frame(width: flag.size.width, height: flag.size.height)
                    .scaleEffect(0.6)
                Text(publicIp.countryName.uppercased())
                    .font(.system(size: 11))
                    .padding(.leading, -10)
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
            
            if appState.current.safetyType == .unknown {
                Button(Constants.menuItemAddAsAllowedIpWithCompletePrivacy) {
                    addAllowedIp(safetyType: .compete)
                }
                Button(Constants.menuItemAddAsAllowedIpWithSomePrivacy) {
                    addAllowedIp(safetyType: .some)
                }
            }
        }
    }
    
    private var ipLabel: String {
        switch appState.network.status {
            case .off: return Constants.offline
            default: return appState.network.isObtainingIp
                ? Constants.obtainingIp
                : appState.network.publicIp?.ipAddress ?? Constants.none
        }
    }
    
    private var ipColor: Color {
        appState.monitoring.isEnabled
            ? safetyColor
            : .primary
    }
    
    private var shouldShowSafetySection: Bool {
        appState.current.safetyType != .unknown
        && appState.network.status != .off
    }
    
    private var safetyColor: Color {
        getSafetyColor(
            safetyType: appState.current.safetyType,
            colorScheme: colorScheme)
    }
    
    // MARK: Private functions
    
    private func addAllowedIp(safetyType: SafetyType) {
        guard let publicIp = appState.network.publicIp
        else { return }
        
        let ip = IpInfo(
            ipAddress: publicIp.ipAddress,
            ipAddressInfo: publicIp,
            safetyType: safetyType
        )
        
        ipService.addAllowedPublicIp(publicIp: ip)
    }
}

#Preview {
    CurrentIpView().environmentObject(AppState())
}
