//
//  RMEpisode.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/13.
//

import Foundation

struct RMEpisode : Codable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}
