//
//  Types.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/16/21.
//

import Foundation

struct TankGamePhysicsCategory {
    static let Player: UInt32 = 0b01
    static let Boundary: UInt32 = 0b11
    static let Missile: UInt32 = 0b100
    static let Powerup: UInt32 = 0b101
    static let Bomb: UInt32 = 0b111
}
