//
//  Extensions.swift
//  RickAndMorty
//
//  Created by Mark Kim on 2023/6/15.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...){
        views.forEach({
            addSubview($0)
        })
    }
}
