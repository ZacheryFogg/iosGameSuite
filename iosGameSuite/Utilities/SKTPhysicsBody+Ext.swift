//
//  SKTPhysicsBody+Ext.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/30/21.
//

import SpriteKit

extension SKPhysicsBody {
  /// Makes the physics body an ideal object without friction or drag
  /// or energy losses due to collisions
  /// - returns: self, but with body set up to be ideal. Useful for chaining.
  func ideal() -> SKPhysicsBody {
    self.friction = 0
    self.linearDamping = 0
    self.angularDamping = 0
    self.restitution = 1
    return self
  }

  /// Makes the physics body ignore forces, but still participate in
  /// collisions. Useful for walls. You can still manually move it
  /// in your update function or in response to taps.
  /// - returns: self, but with body set up to be manually moved. Useful for chaining.
  func manualMovement() -> SKPhysicsBody {
    self.isDynamic = false
    self.allowsRotation = false
    self.affectedByGravity = false
    return self
  }
}
