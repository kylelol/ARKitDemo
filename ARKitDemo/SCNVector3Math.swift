//
//  SCNVector3Math.swift
//  ARKitDemo
//
//  Created by Kyle Kirkland on 4/17/18.
//  Copyright © 2018 Kirkland Enterprises. All rights reserved.
//

import Foundation
import SceneKit

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

extension SCNVector3 {
    
    func length() -> Float {
        return sqrt(x * x + y * y + z * z)
    }
    
    func distance(_ vector: SCNVector3) -> Float {
        return SCNVector3(x: x - vector.x, y: y - vector.y, z: z - vector.z).length()
    }
    
}
