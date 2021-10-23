//
//  GameViewController.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 10/17/21.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? { // I think that this takes the ViewControllers view and casts is as an instace of SKView
            let scene = MenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
    
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = false // draw physics bodies so that we can easily see how they behave
        }
    }

}



/*
Notes:
 
 SKNode is the basic building block of SpriteKit games
    - organized in tree structure; parent is SKScene
 
 SKScene
    - Scene Node executes update loop and so influences its children
    - Each Frames Loop: -update:  ->    SKScene evaluates actions   ->    didEvaluateActions()     ->  SKScene simulates physics   -> didSimulatePhysics()    -> SkView renders the scene
 
 - Each node has its own coordinate sytem that is within its parents and will be its childs
 
 - SKNodes are not able to draw themselves
 
 Frame - square that surrounds a node, enclosing rectangle of the node
 
 
SKSpriteNode   - can draw itself
               - is subclass of SKNode
 
Nodes can have PhysicsBodies, and phycis simulation will calculate behavior for all physicsbodies
 
 
 */
