//
//  ShellAccessible.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import Foundation

protocol ShellAccessible {
    func safeShellAsync(_ command: String) async throws -> String
    func rootShell(command: String) throws -> String
}

extension ShellAccessible {
    @discardableResult
    func safeShellAsync(_ command: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let task = Process()
            let pipe = Pipe()
            
            task.standardOutput = pipe
            task.standardError = pipe
            task.arguments = ["-c", command]
            task.executableURL = URL(fileURLWithPath: Constants.zshPath)
            task.standardInput = nil
            
            task.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                guard let output = String(data: data, encoding: .utf8) else {
                    continuation.resume(throwing: ShellError.invalidOutput(command: command))
                    return
                }
                guard process.terminationStatus == 0 else {
                    continuation.resume(throwing: ShellError.commandFailed(
                        command: command,
                        underlyingError: output))
                    return
                }
                continuation.resume(returning: output)
            }
            
            do {
                try task.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    @discardableResult
    func rootShell(command: String) throws -> String {
        let escapedCommand = command.replacingOccurrences(of: "\"", with: "\\\"")
        let appleScriptSource = "do shell script \"\(escapedCommand)\" with administrator privileges"
        
        var error: NSDictionary?
        let appleScript = NSAppleScript(source: appleScriptSource)
        
        guard let result = appleScript?.executeAndReturnError(&error) else {
            let errorMessage = error?.description ?? String()
            
            throw ShellError.permissionDenied(
                command: command,
                underlyingError: errorMessage)
        }
        
        let output = result.description
        
        guard !output.isEmpty else {
            throw ShellError.invalidOutput(command: command)
        }
        
        return output
    }
}
