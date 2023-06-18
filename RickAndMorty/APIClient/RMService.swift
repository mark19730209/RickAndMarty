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
    
    enum RMServiceError:Error{
        case failedToCreateRequest
        case failedToGetData
    }
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
        guard let urlRequest = self.request(from: request) else {
            completion(.failure(RMServiceError.failedToCreateRequest))
            return
        }
//        print("API Call:\(request.url?.absoluteString ?? "")")
        let task = URLSession.shared.dataTask(with: urlRequest) {data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? RMServiceError.failedToGetData))
                return
            }
            //Decode response
            do{
//                let json = try JSONSerialization.jsonObject(with: data)
//                print(String(describing: json))
                let result = try JSONDecoder().decode(type.self, from: data)
                completion(.success(result))
            }
            catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    //MARK - private
    private func request(from rmRequest:RMRequest)->URLRequest? {
        guard let url = rmRequest.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = rmRequest.httpMethod
        return request
    }
}
