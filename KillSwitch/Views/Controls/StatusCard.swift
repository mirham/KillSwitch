//
//  StatusCard.swift
//  KillSwitch
//
//  Created by UglyGeorge on 07.05.2026.
//

import SwiftUI

struct StatusCard<StatusContent: View, TrailingContent: View>: View {
    let imageName: String
    let title: String
    let cardBackgroundColor: Color
    let cardBorderColor: Color
    @ViewBuilder let statusContent: () -> StatusContent
    @ViewBuilder let trailingContent: () -> TrailingContent
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(cardBorderColor, lineWidth: 0.6)
                )
            HStack(alignment: .center) {
                Image(systemName: imageName)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 5)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                    statusContent()
                }
                Spacer()
                trailingContent()
                    .padding(.trailing, 5)
            }
            .padding(5)
        }
        .frame(width: 200, height: 55)
    }
}
