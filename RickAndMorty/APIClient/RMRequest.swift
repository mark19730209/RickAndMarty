//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/14.
//

import Foundation

/// Object that represents a singlet API Call
final class RMRequest{
    //Base url
    //Endpoint
    //path components
    //Query parameters
    //https://rickandmortyapi.com/api/character/2
    /// API constants
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
        
    }
    
    /// Desired endpoint
    private let endpoint:RMEndpoint
    
    /// path componets for API, if any
    private let pathComponets:Set<String>
    
    /// Query arguments for API, if any
    private let queryParameters:[URLQueryItem]
    
    /// Constructed url for the api request in string format
    private var urlString:String{
        var string = Constants.baseUrl
        string+="/"
        string+=endpoint.rawValue
        
        if(!pathComponets.isEmpty){
            pathComponets.forEach({
                string += "/\($0)"
            })
            
        }
        
        if(!queryParameters.isEmpty){
            string += "?"
            let argumentString = queryParameters.compactMap({
                guard let value = $0.value else {return nil}
                
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            string += argumentString

            
        }
        
        return string
    }
    /// Computed & constructed API url
    public var url:URL?{
        return URL(string: urlString)
    }
    
    /// Desired http method
    public let httpMethod = "GET"
    //MARK - public
    
    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponets: Collection of path componet
    ///   - queryParameters: Collection of query parameters
    public init(
        endpoint: RMEndpoint,
        pathComponets:Set<String> = [],
        queryParameters:[URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponets = pathComponets
        self.queryParameters = queryParameters
    }
}
