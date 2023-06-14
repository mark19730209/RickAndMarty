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
    static let share = RMService()
    
    /// Privatized constructor
    private init(){}
    
    /// Send Rick and Morty API Call
    /// - Parameters:
    ///   - request: request instance
    ///   - completion: callback with data or error
    public func execute(_ request:RMRequest, completion:@escaping () -> Void ){
        
    }
}
