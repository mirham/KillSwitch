//
//  ImageExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 06.07.2024.
//

import SwiftUI

extension CIImage {
    func asCGImage(context: CIContext? = nil) -> CGImage? {
        let ctx = context ?? CIContext(options: nil)
        return ctx.createCGImage(self, from: self.extent)
    }
    
    func asNSImage(pixelsSize: CGSize? = nil, repSize: CGSize? = nil) -> NSImage? {
        let rep = NSCIImageRep(ciImage: self)
        if let ps = pixelsSize {
            rep.pixelsWide = Int(ps.width)
            rep.pixelsHigh = Int(ps.height)
        }
        if let rs = repSize {
            rep.size = rs
        }
        let updateImage = NSImage(size: rep.size)
        updateImage.addRepresentation(rep)
        return updateImage
    }
}
