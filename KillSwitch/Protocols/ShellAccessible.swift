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
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    @discardableResult
    func rootShell(command: String) throws -> String {
        var error: NSDictionary?
        
        if let output =  NSAppleScript(source: "do shell script \"\(command)\" with administrator privileges")?.executeAndReturnError(&error) {
            return output.description
        }
        
        throw error?.description.errorDescription ?? String()
    }
}
