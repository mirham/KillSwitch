//
//  SecurityBadgeView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import SwiftUI

struct SecurityBadgeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    let securityType: SecurityType
    let isHighRisk: Bool
    let securityColor: Color
    let showDetailedIssues: Bool
    
    private var riskItems: [RiskItem] {
        [
            RiskItem(
                text: Constants.riskLocationServicesEnabled,
                isVisible: appState.system.locationServicesEnabled),
            RiskItem(
                text: Constants.riskDnsLeakDetected,
                isVisible: appState.network.hasDnsLeak),
            RiskItem(
                text: Constants.riskWebRtcLeakDetected,
                isVisible: appState.network.hasWebRtcLeak)
        ]
    }
    
    var body: some View {
        VStack(spacing: 5) {
            securityHeader
            if showDetailedIssues && isHighRisk {
                riskWarningText
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(securityColor.opacity(0.25))
        .overlay(rectangleStroke)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var securityHeader: some View {
        HStack(spacing: 6) {
            Text(securityType.fullDesctiption.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(securityColor)
                .kerning(1.2)
        }
    }
    
    @ViewBuilder
    private var riskWarningText: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(riskItems.indices, id: \.self) { index in
                if riskItems[index].isVisible {
                    HStack(alignment: .top, spacing: 8) {
                        Text(Constants.bullet)
                        Text(riskItems[index].text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .font(.system(size: 10))
        .opacity(0.6)
    }
    
    @ViewBuilder
    private var rectangleStroke: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(securityColor.opacity(0.4), lineWidth: 1)
    }
    
    // MARK: Inner types
    
    private struct RiskItem {
        let text: String
        let isVisible: Bool
    }
}

