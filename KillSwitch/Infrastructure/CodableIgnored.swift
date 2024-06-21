//
//  CodableIgnored.swift
//  KillSwitch
//
//  Created by UglyGeorge on 19.06.2024.
//

import Foundation

@propertyWrapper
public struct CodableIgnored<T>: Codable {
    public var wrappedValue: T?
    
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        // Do nothing
    }
}
