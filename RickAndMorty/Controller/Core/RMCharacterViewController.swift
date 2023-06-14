//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/13.
//

import UIKit

/// Controler to show and search for characters
final class RMCharacterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Character"
        
        let request = RMRequest(
            endpoint: .character,
//            pathComponets: ["1"]
            queryParameters: [
                URLQueryItem(name: "name", value: "rick"),
                URLQueryItem(name: "status", value: "alive")
            ]
        )
//        print(request.url)
//        
//        RMService.shared.execute(request, expecting: RMCharacter.self) { result in
//            switch result {
//            case .success(RMCharacter)
//            }
//        }
    }

}
