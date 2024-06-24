//
//  Extensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.06.2024.
//

import SwiftUI

extension View {
    func isHidden(hidden: Bool = false, remove: Bool = false) -> some View {
        modifier(
            IsHiddenModifier(
                hidden: hidden,
                remove: remove))
    }
}

extension View {
    func pointerOnHover() -> some View {
        modifier(PointerOnHoverModifier())
    }
}

extension KeyedDecodingContainer {
    public func decode<T>(
        _ type: CodableIgnored<T>.Type,
        forKey key: Self.Key) throws -> CodableIgnored<T>{
        return CodableIgnored(wrappedValue: nil)
    }
}

extension KeyedEncodingContainer {
    public mutating func encode<T>(
        _ value: CodableIgnored<T>,
        forKey key: KeyedEncodingContainer<K>.Key) throws{
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Task where Failure == Error {
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) {
        let semaphore = DispatchSemaphore(value: 0)
        
        Task(priority: priority) {
            defer { semaphore.signal() }
            return try await operation()
        }
        
        semaphore.wait()
    }
}

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
