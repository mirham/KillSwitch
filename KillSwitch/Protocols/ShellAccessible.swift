//
//  ShellAccessible.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.07.2024.
//

import Foundation

protocol ShellAccessible {
    func safeShell(_ command: String) throws -> String
    func rootShell(command: String) throws -> String
}

extension ShellAccessible {
    @discardableResult
    func safeShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: Constants.zshPath)
        task.standardInput = nil
        
        try task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        guard let output = String(data: data, encoding: .utf8)
        else { throw ShellError.invalidOutput(command: command) }
        
        guard task.terminationStatus == 0
        else {
            throw ShellError.commandFailed(
                command: command,
                underlyingError: output)
        }
        
        return output
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
