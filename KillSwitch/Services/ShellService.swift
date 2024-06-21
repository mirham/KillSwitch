//
//  NetworkManagementService.swift
//  KillSwitch
//
//  Created by UglyGeorge on 04.06.2024.
//

import Foundation

class ShellService{

    static let shared = ShellService()
    
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
}
