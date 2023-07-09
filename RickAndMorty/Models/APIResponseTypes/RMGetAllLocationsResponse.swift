//
//  RMGetAllLocationsResponse.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/7/9.
//

import Foundation

struct RMGetAllLocationsResponse: Codable{
    struct Info:Codable {
        let count: Int
        let pages: Int
        let next:String?
        let prev:String?
    }
    let info:Info
    let results:[RMLocation]
}
