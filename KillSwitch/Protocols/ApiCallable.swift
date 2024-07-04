//
//  NetworkServiceBase.swift
//  KillSwitch
//
//  Created by UglyGeorge on 10.06.2024.
//

import Foundation

protocol ApiCallable{
    func callGetApi(urlAddress : String) async throws -> String?
}

extension ApiCallable {
    func callGetApi(urlAddress : String) async throws -> String? {
        do {
            let url = URL(string: urlAddress)!
            let request = URLRequest(url: url)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response  = String(data: data, encoding: String.Encoding.utf8) as String?
            
            return response
        }
    }
}