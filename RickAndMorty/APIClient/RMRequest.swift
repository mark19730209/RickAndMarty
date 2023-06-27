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
//    private let pathComponets:Set<String>
    private let pathComponets:[String]

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
//        pathComponets:Set<String> = [],
        pathComponets:[String] = [],
        queryParameters:[URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponets = pathComponets
        self.queryParameters = queryParameters
    }
    
    /// Attempt to create url
    /// - Parameter url: <#url description#>
    convenience init? (url: URL){
        let string = url.absoluteString
        if !string.contains(Constants.baseUrl){
            return nil
        }
        let trimmed = string.replacingOccurrences(of: Constants.baseUrl+"/", with: "")
        if trimmed.contains("/"){
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty{
                let endpointString = components[0] //Endpoint
                var pathComponents: [String] = []
                if components.count > 1 {
                    pathComponents = components
                    pathComponents.removeFirst()
                }
                if let rmEndpoint = RMEndpoint(
                    rawValue: endpointString
                ){
                    self.init(endpoint: rmEndpoint, pathComponets: pathComponents)
                    return
                }
            }
        }else if trimmed.contains("?"){
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty, components.count >= 2 {
                let endpointString = components[0]
                let queryItemsString = components[1]
                // value=name&value=name
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {
                        return nil
                    }
                    let parts = $0.components(separatedBy: "=")

                    return URLQueryItem(
                        name: parts[0],
                        value: parts[1]
                    )
                })

                if let rmEndpoint = RMEndpoint(rawValue: endpointString) {
                    self.init(endpoint: rmEndpoint, queryParameters: queryItems)
                    return
                }
            }
        }
        return nil
    }
}

extension RMRequest{
    static let listCharactersRequest = RMRequest(endpoint: .character)
}
