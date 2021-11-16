//
//  CGFloat+Ext.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/15/21.
//

import CoreGraphics

extension CGFloat {
    
    func radiansToDegrees() -> CGFloat {
        return (self * 180.0) / CGFloat.pi
    }
    
    func degreesToRadians() -> CGFloat {
        return (self / 180.0) * CGFloat.pi
    }
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat{
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}
