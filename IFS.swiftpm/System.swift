//
//  System.swift
//  IFS
//
//  Created by Kerman on 2023/3/30.
//

import Foundation

class IFSSystem {
    var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var transformations: [CGAffineTransform] = []
    
    convenience init() {
        self.init(transformations: [])
    }
    
    init(transformations: [CGAffineTransform]) {
        self.transformations = transformations
    }
    
    func addTransformation(iHat: CGPoint, jHat: CGPoint, shift: CGPoint) {
        let t = CGAffineTransform(iHat.x, iHat.y, jHat.x, jHat.y, shift.x, shift.y)
        self.transformations.append(t)
    }

    func chaosGameStep() -> CGPoint {
        let t = transformations.randomElement()!
        position = position.applying(t)
        return position
    }
}
