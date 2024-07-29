//
//  MenuBarElement.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.06.2024.
//

import SwiftUI

struct MenuBarElement: View, Equatable {
    
    let image: NSImage
    let id = UUID()
    let key: String
    
    var body: some View {
        Image(nsImage: image)
            .resizable()
            .frame(width: image.size.width, height: image.size.height)
    }
}

