//
//  MenuBarStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation
import SwiftUI

struct MenuBarStatusView : View {
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack{
            Image(renderMenuBarStatusImage(), scale: 1, label: Text(String()))
        }
    }
    
    // MARK: Private functions
    
    @MainActor
    private func renderMenuBarStatusImage() -> CGImage{
        let icon = getIcon()
        let text = getText()
        let renderer = ImageRenderer(content: icon + text)
        let result = renderer.cgImage
        
        return result!
    }
    
    private func getIcon() -> Text {
        var result: Text
        
        switch appState.current.safetyType {
            case .compete:
                result = Text(Image(systemName:Constants.iconCompleteSafety))
            case .some:
                result = Text(Image(systemName:Constants.iconSomeSafety))
            default:
                result = Text(Image(systemName:Constants.iconUnsafe))
        }
        
        result = result
            .foregroundColor(getSafetyColor(safetyType: appState.current.safetyType))
            .font(.system(size: 16.0))
        
        return result
    }
    
    private func getText() -> Text {
        let result = Text((appState.monitoring.isEnabled ? Constants.on : Constants.off).uppercased())
            .font(.system(size: 16.0))
            .bold()
            .foregroundColor(getSafetyColor(safetyType: appState.current.safetyType))
        
        return result
    }
}

#Preview {
    MenuBarStatusView().environmentObject(AppState())
}
