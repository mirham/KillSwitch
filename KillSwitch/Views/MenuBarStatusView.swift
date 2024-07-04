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
        let currentSafetyType = determineCurrentSafetyType()
        
        let icon = getIcon(currentSafetyType: currentSafetyType)
        let text = getText(currentSafetyType: currentSafetyType)
        let renderer = ImageRenderer(content: icon + text)
        let result = renderer.cgImage
        
        return result!
    }
    
    private func getIcon(currentSafetyType: AddressSafetyType) -> Text {
        var result: Text
        
        switch currentSafetyType {
            case .compete:
                result = Text(Image(systemName:Constants.iconCompleteSafety))
            case .some:
                result = Text(Image(systemName:Constants.iconSomeSafety))
            default:
                result = Text(Image(systemName:Constants.iconUnsafe))
        }
        
        result = result.foregroundColor(getMainColor(currentSafetyType: currentSafetyType)).font(.system(size: 16.0))
        
        return result
    }
    
    private func getText(currentSafetyType: AddressSafetyType) -> Text {
        let result = Text((appState.monitoring.isEnabled ? " On" : "Off").uppercased())
            .font(.system(size: 16.0))
            .bold()
            .foregroundColor(getMainColor(currentSafetyType: currentSafetyType))
        
        return result
    }
    
    private func getMainColor(currentSafetyType: AddressSafetyType) -> Color {
        switch currentSafetyType {
            case .compete:
                return Color.green
            case .some:
                return Color.yellow
            default:
                return Color.red
        }
    }
    
    private func determineCurrentSafetyType() -> AddressSafetyType {
        var result = AddressSafetyType.unsafe
        
        let baseContition = appState.network.status == .on
            && appState.monitoring.isEnabled
            && !appState.system.locationServicesEnabled
        
        if (baseContition && appState.current.safetyType == .compete) {
            result = AddressSafetyType.compete
        }
        else if (baseContition && appState.current.safetyType == .some) {
            result = AddressSafetyType.some
        }
        
        return result
    }
}

#Preview {
    MenuBarStatusView()
}
