//
//  CGVector+Ext.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/30/21.
//
import CoreGraphics

extension CGVector {
    func speed() -> CGFloat {
        return sqrt(dx*dx+dy*dy)
    }
    func angle() -> CGFloat {
        return atan2(dy, dx)
    }
}
