//
//  SafetyBadgeView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 22.04.2026.
//

import SwiftUI

struct SafetyBadgeView: View {
    let safetyType: SafetyType
    let isHighRisk: Bool
    let safetyColor: Color
    
    @Binding var isRisky: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            safetyHeader
            riskWarningText
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(safetyColor.opacity(0.25))
        .overlay(capsuleStroke)
        .clipShape(Capsule())
        .onHover(perform: handleHover)
        .animation(.spring(duration: 0.25), value: isRisky)
    }
    
    // MARK: View sections
    
    private var safetyHeader: some View {
        HStack(spacing: 6) {
            Text(safetyType.fullDesctiption.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(safetyColor)
                .kerning(1.2)
            
            if isHighRisk {
                riskInfoIcon
            }
        }
    }
    
    @ViewBuilder
    private var riskInfoIcon: some View {
        Image(systemName: isRisky ? Constants.iconInfoFill : Constants.iconInfo)
            .font(.system(size: 10))
            .foregroundStyle(safetyColor)
    }
    
    @ViewBuilder
    private var riskWarningText: some View {
        if isHighRisk && isRisky {
            Text(Constants.disableLocationServices.uppercased())
                .font(.system(size: 8, weight: .medium))
                .kerning(0.5)
                .multilineTextAlignment(.center)
                .transition(riskWarningTransition)
        }
    }
    
    @ViewBuilder
    private var capsuleStroke: some View {
        Capsule().stroke(safetyColor.opacity(0.4), lineWidth: 1)
    }
    
    private var riskWarningTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        )
    }
    
    private func handleHover(_ hovering: Bool) {
        DispatchQueue.main.async {
            isRisky = hovering
        }
    }
}
