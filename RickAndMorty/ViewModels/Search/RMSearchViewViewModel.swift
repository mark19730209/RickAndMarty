//
//  RMSearchViewViewModel.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/7/11.
//

import Foundation

// Responsibilities
// - show search results
// - show no results view
// - kick off API requests

final class RMSearchViewViewModel {
    let config: RMSearchViewController.Config
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
}
