//
//  CheckToggleStyle.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? Constants.iconCheckmark : Constants.iconCircle)
                    .foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? Constants.checked : Constants.unchecked))
                    .imageScale(.large)
            }
        }
        .buttonStyle(.plain)
    }
}
