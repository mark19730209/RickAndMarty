//
//  RMGetAllEpisodesResponse.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/30.
//

import Foundation

struct RMGetAllEpisodesResponse: Codable{
    struct Info:Codable {
        let count: Int
        let pages: Int
        let next:String?
        let prev:String?
    }
    let info:Info
    let results:[RMEpisode]
}
