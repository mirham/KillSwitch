//
//  ConnectionItem.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.04.2026.
//

import SwiftUI

struct ConnectionItem: View {
    let interface: NetworkInterface
    
    var body: some View {
        HStack {
            typeColumn
            infoColumn
            Spacer()
        }
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(8)
        .help(interface.friendlyName ?? interface.name)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var typeColumn: some View {
        VStack(alignment: .center) {
            iconView
            Text(interface.type.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(interface.type.color)
        }
        .padding(5)
        .frame(width: 60)
    }
    
    @ViewBuilder
    private var infoColumn: some View {
        VStack(alignment: .leading) {
            if let friendlyName = interface.friendlyName {
                Text(friendlyName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            
            HStack {
                typeBadge
                nameBadge
            }
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        Image(systemName: interface.type.icon)
            .font(.system(size: 14))
            .foregroundStyle(interface.type.color)
            .frame(width: 20, height: 20)
    }
    
    @ViewBuilder
    private var typeBadge: some View {
        Text(interface.isPhysical ? Constants.physical : Constants.virtual)
            .badge(color: .primary)
    }
    
    @ViewBuilder
    private var nameBadge: some View {
        Text(interface.name)
            .badge(color: .primary)
    }
}
