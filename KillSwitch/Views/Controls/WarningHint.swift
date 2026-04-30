//
//  WarningHint.swift
//  KillSwitch
//
//  Created by UglyGeorge on 30.04.2026.
//

import SwiftUI

struct WarningHint: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: Constants.iconWarning)
                .foregroundColor(.yellow)
                .font(.system(size: 10))
                .opacity(0.7)
            Text(linksIn: text)
                .font(.callout)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.yellow.opacity(0.2), lineWidth: 1)
        )
        .padding(.leading, 20)
        .padding(.trailing,20)
        .opacity(0.8)
    }
}
