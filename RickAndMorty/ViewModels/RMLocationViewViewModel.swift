//
//  RMLocationViewViewModel.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/7/7.
//

import Foundation

final class RMLocationViewViewModel {
    private var locations: [RMLocation] = []
    
    // Location response info
    //Will contain next url, if present
    
    private var cellViewModels: [String] = []
    
    init(){
        
    }
    
    public func fetchLocations(){
//        let request = RMRequest(endpoint: .location)
        RMService.shared.execute(.listLocataionRequest, expecting: String.self){ result in
            switch result {
            case .success(let model):
                break
            case .failure(let error):
                break
            }
        }
    }
    
    private var hasMoreResults: Bool {
        return false
    }
}
