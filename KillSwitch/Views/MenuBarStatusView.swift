//
//  MenuBarStatusView.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.06.2024.
//

import Foundation
import SwiftUI

struct MenuBarStatusView: View {
    @EnvironmentObject var monitoringService: MonitoringService
    
    var body: some View {
        HStack{
            switch monitoringService.isMonitoringEnabled {
                case true:
                    let title =  
                    Text(Image(systemName: "shield.lefthalf.filled.badge.checkmark"))
                        .foregroundColor(.green)
                        .font(.system(size: 16.0))
                    + Text(" On".uppercased())
                        .font(.system(size: 16.0))
                        .bold()
                        .foregroundColor(Color.green)
                    let renderer = ImageRenderer(content: title)
                    let cgImage = renderer.cgImage
                    Image(cgImage!, scale: 1, label: Text(""))
                case false:
                    let title =  
                    Text(Image(systemName: "shield.lefthalf.filled.slash"))
                        .foregroundColor(.red)
                        .font(.system(size: 16.0))
                    + Text(" Off".uppercased())
                        .font(.system(size: 16.0))
                        .bold()
                        .foregroundColor(Color.red)
                    let renderer = ImageRenderer(content: title)
                    let cgImage = renderer.cgImage
                    Image(cgImage!, scale: 1, label: Text(""))
            }
        }
    }
}

#Preview {
    MenuBarStatusView()
}

