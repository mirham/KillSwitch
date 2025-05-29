//
//  KeyedContainerExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

import Foundation

extension KeyedDecodingContainer {
    public func decode<T>(
        _ type: CodableIgnored<T>.Type,
        forKey key: Self.Key) throws -> CodableIgnored<T> {
            return CodableIgnored(wrappedValue: nil)
        }
}

extension KeyedEncodingContainer {
    public mutating func encode<T>(
        _ value: CodableIgnored<T>,
        forKey key: KeyedEncodingContainer<K>.Key) throws {}
}
