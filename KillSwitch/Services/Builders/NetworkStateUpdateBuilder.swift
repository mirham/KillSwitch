//
//  NetworkStateUpdateBuilder.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.05.2025.
//

final class NetworkStateUpdateBuilder {
    private var update = NetworkStateUpdate()
    
    @discardableResult
    func withStatus(_ status: NetworkStatusType) -> Self {
        update.status = status
        
        return self
    }
    
    @discardableResult
    func withPublicIp(_ publicIp: IpInfoBase?) -> Self {
        update.publicIp = publicIp
        update.forceUpdatePublicIp = true
        
        return self
    }
    
    @discardableResult
    func withActiveNetworkInterfaces(_ interfaces: [NetworkInterface]) -> Self {
        update.activeNetworkInterfaces = interfaces
        
        return self
    }
    
    @discardableResult
    func withPhysicalNetworkInterfaces(_ interfaces: [NetworkInterface]) -> Self {
        update.physicalNetworkInterfaces = interfaces
        
        return self
    }
    
    @discardableResult
    func withIsDisconnected(_ isDisconnected: Bool) -> Self {
        update.isDisconnected = isDisconnected
        
        if isDisconnected {
            update.publicIp = nil
            update.forceUpdatePublicIp = true
        }
        
        return self
    }
    
    @discardableResult
    func withIsFetchingIp(_ isFetchingIp: Bool) -> Self {
        update.isFetchingIp = isFetchingIp
        
        return self
    }
    
    @discardableResult
    func withHasDnsLeakIp(_ hasDnsLeak: Bool) -> Self {
        update.hasDnsLeak = hasDnsLeak
        
        return self
    }
    
    @discardableResult
    func withHasWebRtcLeakIp(_ hasWebRtcLeak: Bool) -> Self {
        update.hasWebRtcLeak = hasWebRtcLeak
        
        return self
    }
    
    func build() -> NetworkStateUpdate {
        update
    }
}
