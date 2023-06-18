//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/16.
//

import Foundation

final class RMCharacterDetailViewViewModel{
    private let character : RMCharacter
    init(character:RMCharacter){
        self.character = character
    }
    public var title:String{
        character.name.uppercased()
    }
}
