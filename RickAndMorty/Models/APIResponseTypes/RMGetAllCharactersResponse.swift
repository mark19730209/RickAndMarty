//
//  RMGetAllCharactersResponse.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/14.
//

import Foundation

struct RMGetAllCharactersResponse: Codable{
    struct Info:Codable {
        let count: Int
        let pages: Int
        let next:String?
        let prev:String?
    }
    let info:Info
    let results:[RMCharacter]
}
