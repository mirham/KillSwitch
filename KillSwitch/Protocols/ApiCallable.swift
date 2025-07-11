//
//  ApiCallable.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

protocol ApiCallable{
    func callGetApiAsync(apiUrl : String, timeoutInterval: Double) async throws -> String
}

extension ApiCallable {
    func callGetApiAsync(apiUrl : String, timeoutInterval: Double) async throws -> String {
        let defaultResponse = String()
        
        guard !Task.isCancelled else { return defaultResponse }
        
        do {
            let url = URL(string: apiUrl)!
            let request = URLRequest(url: url)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response  = String(data: data, encoding: String.Encoding.utf8) as String?
            
            return response ?? String()
        }
    }
}
