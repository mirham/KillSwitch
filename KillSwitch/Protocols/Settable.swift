//
//  Settable.swift
//  KillSwitch
//
//  Created by UglyGeorge on 26.06.2024.
//

import Foundation

protocol Settable {
    func readSetting<T: Codable>(key: String) -> T?
    func writeSetting<T: Codable>(newValue: T, key: String)
    func readSettingsArray<T: Codable>(key: String) -> [T]?
    func writeSettingsArray<T: Codable>(newValues: [T], key: String)
}

extension Settable {
    func readSetting<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        let result = try? JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    func writeSetting<T: Codable>(newValue: T, key: String) {
        let data = try? JSONEncoder().encode(newValue)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func readSettingsArray<T: Codable>(key: String) -> [T]? {
        if let objects = UserDefaults.standard.value(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [T] {
                return objectsDecoded
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func writeSettingsArray<T: Codable>(newValues: [T], key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newValues){
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func readSettingsDictionary<K: Codable & Hashable, V: Codable>(key: String) -> [K: V]? {
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([K: V].self, from: data) {
                return decoded
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func writeSettingsDictionary<K: Codable & Hashable, V: Codable>(newValues: [K: V], key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newValues) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
