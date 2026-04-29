//
//  DnsService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 29.04.2026.
//

import Foundation
import Factory

final class DnsService: DnsServiceType, ShellAccessible {
    @Injected(\.loggingService) private var logger
    @Injected(\.appState) private var appState
    
    private var pollingTask: Task<Void, Never>?
    private let pollingInterval: TimeInterval = 15
    
    deinit {
        pollingTask?.cancel()
    }
    
    func startMonitoring() {
        guard pollingTask == nil
        else { return }
        
        pollingTask = Task { [weak self] in
            guard let self
            else { return }
            
            while !Task.isCancelled {
                if self.appState.monitoring.isEnabled
                    && self.appState.network.status == .on {
                    await self.checkForLeakAsync()
                }
                
                try? await Task.sleep(for: .seconds(self.pollingInterval))
            }
        }
        
        logger.write(
            message: String(
                format: Constants.logDnsMonitoringStarted,
                Int(pollingInterval)),
            type: .success)
    }
    
    func stopMonitoring() {
        pollingTask?.cancel()
        pollingTask = nil
        
        logger.write(
            message: Constants.logDnsMonitoringStopped,
            type: .success)
    }
    
    @discardableResult
    func checkForLeakAsync() async -> Bool {
        logger.write(
            message: Constants.logDnsCheckInitiated,
            type: .info)
        
        let output: String
        
        do {
            output = try await safeShellAsync(Constants.shDnsCommand)
        } catch {
            logger.write(
                message: String(
                    format: Constants.logDnsCheckFailed,
                    error.localizedDescription),
                type: .error)
            
            return false
        }
        
        let resolvers = parseResolvers(from: output)
        
        guard !resolvers.isEmpty
        else {
            logger.write(
                message: Constants.logDnsNoResolversFound,
                type: .warning)
            
            return false
        }
        
        guard resolvers.contains(where: { $0.isVpn })
        else {
            logger.write(
                message: Constants.logDnsNoVpnDetected,
                type: .success)
            return false
        }
        
        let leakingResolvers = resolvers.filter { isLeaking(resolver: $0) }
        let result = !leakingResolvers.isEmpty
        
        logResult(
            allResolvers: resolvers,
            leakingResolvers: leakingResolvers,
            isLeakDetected: result)
        
        return result
    }
    
    // MARK: Private functions
    
    private func parseResolvers(from output: String) -> [DnsResolver] {
        let mainSection = output
            .components(separatedBy: Constants.scutilScopedQueriesHeader)
            .first ?? output
        
        var seen = Set<String>()
        
        return mainSection
            .components(separatedBy: Constants.doubleNewline)
            .compactMap { parseResolverBlock($0) }
            .filter { resolver in
                let key = "\(resolver.interfaceName ?? Constants.nilPlaceholder)|\(resolver.nameservers.joined())"
                
                return seen.insert(key).inserted
            }
    }
    
    private func parseResolverBlock(_ block: String) -> DnsResolver? {
        let lines = block
            .components(separatedBy: Constants.newline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard let header = lines.first,
              header.hasPrefix(Constants.scutilResolverPrefix)
        else { return nil }
        
        let index = Int(header.replacingOccurrences(
            of: Constants.scutilResolverPrefix,
            with: String())) ?? 0
        var nameservers: [String] = []
        var ifaceName: String?
        var domain: String?
        
        for line in lines.dropFirst() {
            if line.hasPrefix(Constants.scutilNameserverPrefix),
               let ip = line.components(separatedBy: Constants.colon)
                .last?
                .trimmingCharacters(in: .whitespaces) {
                nameservers.append(ip)
            } else if line.hasPrefix(Constants.scutilIfIndexPrefix),
                let match = line.range(
                    of: Constants.regexScutilParenthesesPattern,
                    options: .regularExpression) {
                ifaceName = String(line[match]).trimmingCharacters(
                    in: CharacterSet(charactersIn: Constants.parentheses))
            } else if line.hasPrefix(Constants.scutilDomainPrefix) {
                domain = line.components(separatedBy: Constants.colon)
                    .last?
                    .trimmingCharacters(in: .whitespaces)
            }
        }
        
        guard !nameservers.isEmpty
        else { return nil }
        
        return DnsResolver(
            index: index,
            interfaceName: ifaceName,
            nameservers: nameservers,
            domain: domain)
    }
    
    private func isLeaking(resolver: DnsResolver) -> Bool {
        guard let iface = resolver.interfaceName
        else { return true }
        
        return Constants.physicalInterfacePrefixes
            .contains(where: { iface.hasPrefix($0) })
    }
    
    private func logResult(
        allResolvers: [DnsResolver],
        leakingResolvers: [DnsResolver],
        isLeakDetected: Bool
    ) {
        let leakingIndices = Set(leakingResolvers.map { $0.index })
        
        for resolver in allResolvers {
            let networkInterface = resolver.interfaceName ?? Constants.logUnboundInterface
            let servers = resolver.nameservers.joined(separator: Constants.serverSeparator)
            let domainSuffix = resolver.domain.map { String(format: Constants.logDomainSuffix, $0) } ?? String()
            let leakFlag = leakingIndices.contains(resolver.index)
                ? Constants.logLeakFlag
                : String()
            
            logger.write(
                message: String(format: Constants.logDnsResolverEntry, resolver.index, networkInterface, servers, domainSuffix, leakFlag),
                type: isLeakDetected ? .warning : .info)
        }
        
        if isLeakDetected {
            let leakDetails = leakingResolvers
                .map(\.details)
                .joined(separator: Constants.leakDetailSeparator)
            
            logger.write(
                message: String(
                    format: Constants.logDnsLeakDetected,
                    leakingResolvers.count,
                    leakDetails),
                type: .warning)
        } else {
            let vpnInterfaces = allResolvers
                .filter(\.isVpn)
                .compactMap(\.interfaceName)
                .joined(separator: Constants.serverSeparator)
            
            logger.write(
                message: String(format: Constants.logDnsCheckPassed, vpnInterfaces.isEmpty ? Constants.logNoSpecificInterface : vpnInterfaces),
                type: .success)
        }
    }
    
    // MARK: Inner types
    
    private struct DnsResolver {
        let index: Int
        let interfaceName: String?
        let nameservers: [String]
        let domain: String?
        
        var isVpn: Bool {
            guard let iface = interfaceName
            else { return false }
            
            return Constants.vpnInterfacePrefixes.contains(
                where: { iface.hasPrefix($0) }
            )
        }
        
        var details: String {
            let interfaceName = interfaceName ?? Constants.logSystemWide
            let servers = nameservers.joined(separator: Constants.serverSeparator)
            
            return String(format: Constants.logNetworkInterfaceDetails, interfaceName, servers)
        }
        
    }
}
