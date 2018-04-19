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

        runSesssion()
        trackingInfo.text = ""
        messageLabel.text = ""
        distanceLabel.isHidden = true
        selectVase()
    }
    
    // MARK: Actions
    
    @IBAction func didTapChairButton(_ sender: Any) {
        currentIntent = .placeObject("art.scnassets/chair/chair.scn")
        selectButton(chairButton)
    }
    
    @IBAction func didTapCandleButton(_ sender: Any) {
        currentIntent = .placeObject("art.scnassets/candle/candle.scn")
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
        currentIntent = .placeObject("art.scnassets/vase/vase.scn")
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
    
    private func runSesssion() {
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        #if DEBUG
            sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        #endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let hit = sceneView.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            return
        } else if let hit = sceneView.hitTest(viewCenter, types: [.featurePoint]).last {
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            return
        }
    }
    
    func measure(fromNode: SCNNode, toNode: SCNNode) {
        let lineNode = createLineNode(fromNode: fromNode, toNode: toNode)
        lineNode.name = "line"
        self.objects.append(lineNode)
        sceneView.scene.rootNode.addChildNode(lineNode)
        
        let dist = fromNode.position.distance(toNode.position)
        let measurementValue = String(format: "%.2f", dist)
        distanceLabel.text = "Distance: \(measurementValue) m"
    }
    
    func updateMeasuringNodes() {
        guard measuringNodes.count > 1 else { return }
        
        let firstNode = measuringNodes[0]
        let secondNode = measuringNodes[1]
        
        let showMeasuring = measuringNodes.count == 2
        distanceLabel.isHidden = !showMeasuring
        
        if showMeasuring {
            measure(fromNode: firstNode, toNode: secondNode)
        } else if measuringNodes.count > 2 {
            firstNode.removeFromParentNode()
            secondNode.removeFromParentNode()
            measuringNodes.removeFirst(2)
            
            for node in sceneView.scene.rootNode.childNodes {
                if node.name == "line" {
                    node.removeFromParentNode()
                }
            }
        }
    }
    
    func updateTrackingInfo() {
        guard let frame = sceneView.session.currentFrame else { return }
        
        switch frame.camera.trackingState {
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                trackingInfo.text = "Limited Tracking: Excessive Motion"
            case .insufficientFeatures:
                trackingInfo.text = "Limited Tracking: Insufficent Features"
            default:
                trackingInfo.text = "Limited Tracking"
            }
        default:
            trackingInfo.text = ""
        }
        
        guard let lightEstimate = frame.lightEstimate?.ambientIntensity else { return }
        
        if lightEstimate < 100 {
            trackingInfo.text = "Limited Tracking: Too Dark"
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        showMessage(error.localizedDescription, label: messageLabel, forDuration: 2.0)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        showMessage("SessionInteruppted", label: messageLabel, forDuration: 2.0)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        showMessage("Session Resumed", label: messageLabel, forDuration: 2.0)
        removeAllObjects()
        runSesssion()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateTrackingInfo()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let planeNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
                node.addChildNode(planeNode)
                self.objects.append(planeNode)
            } else {
                switch self.currentIntent {
                case .none: break
                case .placeObject(let objectName):
                    let newObject = SCNScene(named: objectName)!.rootNode.clone()
                    self.objects.append(newObject)
                    node.addChildNode(newObject)
                case .measure:
                    let sphereNode = createSphereNode(radius: 0.02)
                    self.objects.append(sphereNode)
                    node.addChildNode(sphereNode)
                    self.measuringNodes.append(node)
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                updatePlaneNode(node.childNodes[0], center: planeAnchor.center, extent: planeAnchor.extent)
            } else {
                self.updateMeasuringNodes()
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        removeChildren(inNode: node)
    }
    
}
