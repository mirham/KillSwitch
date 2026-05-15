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
    
    deinit {
        pollingTask?.cancel()
    }
    
    func startMonitoringAsync() async {
        let snapshot = await MainActor.run {(
            isDnsLeakCheckEnabled: appState.current.isDnsLeakCheckEnabled,
            dnsLeakCheckInterval: appState.userData.dnsLeakCheckInterval
        )}
        
        guard pollingTask == nil, snapshot.isDnsLeakCheckEnabled
        else { return }
        
        logger.write(
            message: String(
                format: Constants.logDnsMonitoringEnabled,
                Int(snapshot.dnsLeakCheckInterval)),
            type: .success)
        
        pollingTask = Task { [weak self] in
            guard let self else { return }
            
            while !Task.isCancelled {
                let isEnabled = await MainActor.run {  self.appState.current.isDnsLeakCheckEnabled }
                let interval = await MainActor.run { self.appState.userData.dnsLeakCheckInterval }
                
                if isEnabled {
                    let hasLeak = await checkForLeakAsync()
                    
                    await updateStatusAsync { builder in
                        builder.withHasDnsLeakIp(hasLeak)
                    }
                }
                
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }
    
    func stopMonitoringAsync() async {
        if pollingTask != nil {
            logger.write(
                message: Constants.logDnsMonitoringDisabled,
                type: .success)
        }
        
        pollingTask?.cancel()
        pollingTask = nil
        
        await updateStatusAsync { builder in
            builder.withHasDnsLeakIp(false)
        }
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
        var interfaceName: String?
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
                interfaceName = String(line[match]).trimmingCharacters(
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
            interfaceName: interfaceName,
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
    
    private func updateStatusAsync(_ configure: (NetworkStateUpdateBuilder) -> NetworkStateUpdateBuilder) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(NetworkStateUpdateBuilder()).build()
        
        await MainActor.run {
            appState.applyNetworkUpdate(update)
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
