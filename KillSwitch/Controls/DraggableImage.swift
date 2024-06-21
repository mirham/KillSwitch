//
//  DraggableImage.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.06.2024.
//

import SwiftUI

struct DragableImage: View {
    
    let image: NSImage
    let id = UUID()
    let label: String
    
    var body: some View {
        Image(nsImage: image)
            .resizable()
            .frame(width: 20, height: 20)
            .onDrag { return NSItemProvider(object: self.image) }
    }
    }

