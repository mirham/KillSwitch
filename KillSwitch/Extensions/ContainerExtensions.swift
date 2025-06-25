//
//  ContainerExtensions.swift
//  KillSwitch
//
//  Created by UglyGeorge on 20.05.2025.
//

import Factory

// MARK: DI registrations

extension Container {
    // MARK: Services registrations
    
    var monitoringService: Factory<MonitoringServiceType> {
        Factory(self) { MonitoringService() }
            .singleton
    }
    
    var networkStatusService: Factory<NetworkStatusServiceType> {
        Factory(self) { NetworkStatusService() }
            .singleton
    }
    
    var ipService: Factory<IpServiceType> {
        Factory(self) { IpService() }
            .singleton
    }
    
    var ipApiService: Factory<IpApiServiceType> {
        Factory(self) { IpApiService() }
            .singleton
    }
    
    var networkService: Factory<NetworkServiceType> {
        Factory(self) { NetworkService() }
            .singleton
    }
    
    var launchAgentService: Factory<LaunchAgentServiceType> {
        Factory(self) { LaunchAgentService() }
            .singleton
    }
    
    var locationService: Factory<LocationServiceType> {
        Factory(self) { LocationService() }
            .singleton
    }
    
    var computerService: Factory<ComputerServiceType> {
        Factory(self) { ComputerService() }
            .singleton
    }
    
    var processService: Factory<ProcessServiceType> {
        Factory(self) { ProcessService() }
            .singleton
    }
    
    var loggingService: Factory<LoggingServiceType> {
        Factory(self) { LoggingService() }
            .singleton
    }
}
