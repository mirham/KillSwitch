//
//  NetworkService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation
import Network
import SystemConfiguration
import Factory

class NetworkService : ServiceBase, ShellAccessible, NetworkServiceType {
    @Injected(\.ipService) private var ipService
    
    func isUrlReachableAsync(url : String) async throws -> Bool {
        do {
            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = Constants.headHttpMethod
            
            let (_, response) = try await URLSession.shared.data(for: request)
            let parsedResponse = (response as? HTTPURLResponse)!
            let result = parsedResponse.statusCode == 200
            
            return result
        }
    }
    
    func refreshPublicIpAsync() async {
        guard !Task.isCancelled else { return }
        
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withIsObtainingIp(true)
            .build())
        
        let publicIp = await fetchPublicIpAsync()
        
        await updateStatusAsync(update: NetworkStateUpdateBuilder()
            .withIsObtainingIp(false)
            .withPublicIp(publicIp)
            .build())
    }
    
    func getPhysicalInterfaces() -> [NetworkInterface] {
        let interfaces = SCNetworkInterfaceCopyAll() as? Array<SCNetworkInterface> ?? []
        
        let result = interfaces.compactMap { interface -> NetworkInterface? in
            guard let interfaceName = SCNetworkInterfaceGetLocalizedDisplayName(interface) as? String else { return nil }
            guard let bsdName = SCNetworkInterfaceGetBSDName(interface) as? String else { return nil }
            
            let isPhysicalInterface = bsdName.hasPrefix(Constants.physicalNetworkInterfacePrefix) &&
                interfaceName.range(of: Constants.physicalNetworkInterfaceExclusion, options: .caseInsensitive) == nil
            
            guard isPhysicalInterface else { return nil }
            
            return NetworkInterface(
                name: bsdName as String,
                type: getNetworkInterfaceTypeByInterfaceName(interfaceName: interfaceName),
                localizedName: interfaceName)
        }
        
        return result
    }
    
    func enableNetworkInterface(interfaceName: String) {
        do {
            try safeShell(String(format: Constants.shCommandEnableNetworkIterface, interfaceName))
            
            loggingService.write(
                message: String(format: Constants.logNetworkInterfaceHasBeenEnabled, interfaceName),
                type: .info)
        }
        catch {
            loggingService.write(
                message: String(format: Constants.logCannotEnableNetworkInterface, interfaceName),
                type: .error)
        }
    }
    
    func disableNetworkInterface(interfaceName: String) {
        do {
            try safeShell(String(format: Constants.shCommandDisableNetworkIterface, interfaceName))
            
            loggingService.write(
                message: String(format: Constants.logNetworkInterfaceHasBeenDisabled, interfaceName),
                type: .info)
        }
        catch {
            loggingService.write(
                message: String(format: Constants.logCannotDisableNetworkInterface, interfaceName),
                type: .error)
        }
    }
    
    // MARK: Private functions
    
    private func getNetworkInterfaceTypeByInterfaceName(interfaceName: String) -> NetworkInterfaceType {
        if (interfaceName.range(of: Constants.physicalNetworkInterfaceWiFi, options: .caseInsensitive) != nil) {
            return NetworkInterfaceType.wifi
        }
        
        if (interfaceName.range(of: Constants.physicalNetworkInterfaceLan, options: .caseInsensitive) != nil) {
            return NetworkInterfaceType.wired
        }
        
        return NetworkInterfaceType.other
    }
    
    private func fetchPublicIpAsync() async -> IpInfoBase? {
        var isPublicIpNotObtained = true
        let shouldFetchPublicIp = isPublicIpNotObtained
        && !Task.isCancelled
        && appState.userData.hasActiveIpApi()
        && appState.network.status == .on
        
        while shouldFetchPublicIp {
            let result = await ipService.getPublicIpAsync(ipApiUrl: nil, withInfo: true)
            
            if result.success {
                isPublicIpNotObtained = false
                
                loggingService.write(
                    message: String(
                        format: Constants.logPublicIp,
                        result.result!.ipAddress,
                        result.result!.countryName),
                    type: .info)
                
                return result.result
            }
        }
        
        return nil
    }
    
    private func updateStatusAsync(update: NetworkStateUpdate) async {
        guard !Task.isCancelled else { return }
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
            appState.objectWillChange.send()
        }
    }
}
