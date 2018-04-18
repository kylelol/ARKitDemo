//
//  UIViewController+Utils.swift
//  ARKitDemo
//
//  Created by Kyle Kirkland on 4/17/18.
//  Copyright © 2018 Kirkland Enterprises. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    var viewCenter: CGPoint {
        let screenSize = view.bounds
        return CGPoint(x: screenSize.width / 2.0, y: screenSize.height / 2.0)
    }
    
    func showMessage(_ message: String, label: UILabel, forDuration duration: Double) {
        label.text = message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if label.text == message {
                label.text = ""
            }
        }
    }
    
}
