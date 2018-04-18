//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Kyle Kirkland on 4/17/18.
//  Copyright © 2018 Kirkland Enterprises. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    enum Intent {
        case none
        case placeObject(String)
        case measure
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var chairButton: UIButton!
    @IBOutlet weak var candleButton: UIButton!
    @IBOutlet weak var measureButton: UIButton!
    @IBOutlet weak var vaseButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var crosshair: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var trackingInfo: UILabel!
    
    var currentIntent: Intent = .none
    var objects: [SCNNode] = []
    var measuringNodes: [SCNNode] = []
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trackingInfo.text = ""
        messageLabel.text = ""
        distanceLabel.isHidden = true
        selectVase()
    }
    
    // MARK: Actions
    
    @IBAction func didTapChairButton(_ sender: Any) {
        currentIntent = .placeObject("Models.scnassets/chair/chair.scn")
        selectButton(chairButton)
    }
    
    @IBAction func didTapCandleButton(_ sender: Any) {
        currentIntent = .placeObject("Models.scnassets/candle/candle.scn")
        selectButton(candleButton)
    }
    
    @IBAction func didTapMeasureButton(_ sender: Any) {
        currentIntent = .measure
        selectButton(measureButton)
    }
    
    @IBAction func didTapVaseButton(_ sender: Any) {
        selectVase()
    }
    
    @IBAction func didTapResetButton(_ sender: Any) {
        removeAllObjects()
        distanceLabel.text = ""
    }

    // MARK: Helpers
    
    private func selectVase() {
        currentIntent = .placeObject("Models.scnassets/vase/vase.scn")
        selectButton(vaseButton)
    }
    
    private func selectButton(_ button: UIButton) {
        unselectAllButtons()
        button.isSelected = true
    }
    
    private func unselectAllButtons() {
        [chairButton, candleButton, measureButton, vaseButton].forEach { button in
            button?.isSelected = false
        }
    }
    
    private func removeAllObjects() {
        objects.forEach { node in
            node.removeFromParentNode()
        }
        
        objects = []
    }
    
}
