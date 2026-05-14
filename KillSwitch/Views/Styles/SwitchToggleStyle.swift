//
//  SwitchToggleStyle.swift
//  KillSwitch
//
//  Created by UglyGeorge on 15.05.2026.
//

import SwiftUI

struct SwitchToggleStyle: ToggleStyle {
    @State private var knobOffset: CGFloat = 0
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Capsule()
                .fill(configuration.isOn ? Color.accentColor : Color.gray.opacity(0.4))
                .frame(width: 46, height: 26)
            
            Circle()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .frame(width: 22, height: 22)
                .offset(x: knobOffset)
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
        .onChange(of: configuration.isOn) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                knobOffset = newValue ? 10 : -10
            }
        }
        .onAppear {
            knobOffset = configuration.isOn ? 10 : -10
        }
    }
}
