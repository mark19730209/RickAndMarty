//
//  RMEndpoint.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/14.
//

import Foundation

/// Represents unique API endpoint
@frozen enum RMEndpoint: String{
    ///Endpoint to get charater info
    case character
    ///Endpoint to get location  info
    case location
    ///Endpoint to get episode  info
    case episode
}
