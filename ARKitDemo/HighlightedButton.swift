//
//  HighlightedButton.swift
//  ARKitDemo
//
//  Created by Kyle Kirkland on 4/17/18.
//  Copyright © 2018 Kirkland Enterprises. All rights reserved.
//

import UIKit

class HighlightedButton: UIButton {

    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.yellow.cgColor
                layer.borderWidth = 3
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
}
