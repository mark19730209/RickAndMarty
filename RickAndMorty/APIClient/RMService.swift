//
//  RMService.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/14.
//

import Foundation

/// Primary API Service object to get Rick and Morty data
final class RMService {
    
    /// share singleton instance
    static let shared = RMService()
    
    /// Privatized constructor
    private init(){}
    
    /// Send Rick and Morty API Call
    /// - Parameters:
    ///   - request: request instance
    ///   - type: The type of object we expect to get back
    ///   - completion: callback with data or error
    public func execute<T: Codable>(
        _ request:RMRequest,
        expecting type: T.Type,
        completion:@escaping (Result<T, Error>) -> Void
    ){
        
    }
}
