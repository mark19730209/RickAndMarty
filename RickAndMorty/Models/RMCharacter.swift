//
//  RMCharacter.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/13.
//

import Foundation

struct RMCharacter:Codable{
    let id: Int
    let name: String
    let status: RMCharacterStatus
    let species: String
    let type: String
    let gender: String
    let origin: RMOrigin
    let location: RMSingleLocation
    let image: String
    let episode: [String]
    let url: String
    let created: String
}


