//
//  NetworkInterfaceInfoService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 21.04.2026.
//

import Foundation
import CoreWLAN
import CoreLocation
import SystemConfiguration

final class NetworkInterfaceInfoService : NSObject, NetworkInterfaceInfoServiceType, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var ssidContinuation: CheckedContinuation<String?, Never>?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func getFriendlyNameAsync(for interface: NetworkInterface) async -> String? {
        switch interface.type {
            case .wifi:
                return await getCurrentSsid()
            case .vpn:
                return getVpnName(forInterface: interface.name)
            default:
                return nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = ssidContinuation
        else { return }
        
        ssidContinuation = nil
        
        switch manager.authorizationStatus {
            case .authorized, .authorizedAlways:
                Task {
                    let ssid = await fetchSsid()
                    continuation.resume(returning: ssid)
                }
            default:
                continuation.resume(returning: nil)
        }
    }

    
    // MARK: Private Functions
    
    private func getCurrentSsid() async -> String? {
        let status = locationManager.authorizationStatus
        
        switch status {
            case .authorized, .authorizedAlways:
                return await fetchSsid()
                
            case .notDetermined:
                return await withCheckedContinuation { continuation in
                    ssidContinuation = continuation
                    locationManager.requestWhenInUseAuthorization()
                }
                
            case .denied, .restricted:
                return nil
                
            @unknown default:
                return nil
        }
    }
    
    @MainActor
    private func fetchSsid() -> String? {
        CWWiFiClient.shared().interface()?.ssid()
    }
    
    private func getVpnName(forInterface bsdName: String) -> String? {
        guard let session = createDynamicStore()
        else { return nil }
        
        // Method 1: Check active services with IPv4
        if let name = findVpnNameInActiveServices(
            bsdName: bsdName,
            session: session) {
            return name
        }
        
        // Method 2: Check via interface state
        if let name = findVpnNameViaInterfaceState(
            bsdName: bsdName,
            session: session) {
            return name
        }
        
        // Method 3: Check PPP configurations
        if let name = findVpnNameInPppServices(
            bsdName: bsdName,
            session: session) {
            return name
        }
        
        return nil
    }
    
    private func createDynamicStore() -> SCDynamicStore? {
        return SCDynamicStoreCreate(
            nil,
            Constants.niiSessionName as CFString,
            nil,
            nil)
    }
    
    private func findVpnNameInActiveServices(
        bsdName: String,
        session: SCDynamicStore) -> String? {
        guard let keys = SCDynamicStoreCopyKeyList(
            session,
            Constants.niiActiveServiceIPv4 as CFString) as? [String]
        else { return nil }
        
        for key in keys {
            guard let dict = SCDynamicStoreCopyValue(
                session,
                key as CFString
            ) as? [String: Any],
                  let interface = dict[Constants.niiInterfaceNameKey] as? String,
                  interface == bsdName
            else { continue }
            
            return resolveUserDefinedName(
                fromKey: key,
                session: session)
        }
        
        return nil
    }
    
    private func findVpnNameViaInterfaceState(
        bsdName: String,
        session: SCDynamicStore) -> String? {
        let interfaceKey = String(format: Constants.niiInterfaceStateIPv4, bsdName)
        
        guard let dict = SCDynamicStoreCopyValue(
            session,
            interfaceKey as CFString
        ) as? [String: Any],
              let serviceID = dict[Constants.niiServiceKey] as? String
        else { return nil }
        
        let setupKey = String(format: Constants.niiServiceSetup, serviceID)
            
        guard let setupDict = SCDynamicStoreCopyValue(
            session,
            setupKey as CFString
        ) as? [String: Any]
        else { return nil }
        
        return setupDict[Constants.niiUserDefinedNameKey] as? String
    }
    
    private func findVpnNameInPppServices(
        bsdName: String,
        session: SCDynamicStore) -> String? {
        guard let keys = SCDynamicStoreCopyKeyList(
            session,
            Constants.niiPPPSetup as CFString)
                as? [String]
        else { return nil }
        
        for key in keys {
            guard let dict = SCDynamicStoreCopyValue(
                session,
                key as CFString
            ) as? [String: Any],
                let interface = dict[Constants.niiInterfaceNameKey] as? String,
                interface == bsdName
            else { continue }
            
            return resolveUserDefinedName(
                fromKey: key,
                session: session)
        }
        
        return nil
    }
    
    private func resolveUserDefinedName(
        fromKey key: String,
        session: SCDynamicStore) -> String? {
        let components = key.components(separatedBy: Constants.slash)
        
        guard let serviceIndex = components.firstIndex(of: Constants.niiService),
              components.count > serviceIndex + 1
        else { return nil }
        
        let serviceID = components[serviceIndex + 1]
        let setupKey = String(format: Constants.niiServiceSetup, serviceID)
        
        guard let setupDict = SCDynamicStoreCopyValue(
            session,
            setupKey as CFString
        ) as? [String: Any]
        else { return nil }
        
        return setupDict[Constants.niiUserDefinedNameKey] as? String
    }
}
