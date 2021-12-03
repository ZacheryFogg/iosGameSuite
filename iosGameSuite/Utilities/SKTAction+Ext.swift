//
//  SKTAction+Ext.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/19/21.
//

import SpriteKit

extension SKAction {

    class func playerSoundFileNamed(_ fileNamed: String) -> SKAction {
        if !effectEnabled {return SKAction() }
        return SKAction.playSoundFileNamed(fileNamed, waitForCompletion: false)
    }
}

private let keyEffect = "keyEffect"

var effectEnabled: Bool = {
    return !UserDefaults.standard.bool(forKey: keyEffect)
}() {
    didSet {
        let value = !effectEnabled
        UserDefaults.standard.set(value, forKey: keyEffect)
        
        if value {
            SKAction.stop()
        }
    }
}
//
//
//
//}
