//
//  ApiCallable.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

protocol ApiCallable{
    func callGetApiAsync(apiUrl: String, timeoutInterval: Double) async throws -> String
}

extension ApiCallable {
    func callGetApiAsync(apiUrl: String, timeoutInterval: Double) async throws -> String {
        let defaultResponse = String()
        
        guard !Task.isCancelled
        else { return defaultResponse }
        
        guard let url = URL(string: apiUrl)
        else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpMethod = Constants.httpMethodGet
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let response = String(data: data, encoding: .utf8)
        else { throw URLError(.cannotDecodeRawData) }
        
        return response
    }
}
