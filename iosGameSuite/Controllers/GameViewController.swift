//
//  GameViewController.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 10/17/21.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
   
    var menuScene: MenuScene?

    override func loadView() {
        super.loadView()
        self.view = SKView()
        self.view.bounds = UIScreen.main.bounds

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScene()

    }

    func setupScene(){
        if let view = self.view as? SKView, menuScene == nil {
            let scene = MenuScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            print(view.bounds.size)
            view.presentScene(scene)
            self.menuScene = scene
        }
    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Takes the ViewControllers view and casts is as an instace of SKView
//        guard let view = self.view as? SKView else {return}
//
////        let scene = MenuScene(size: view.bounds.size)
//        let scene = MenuScene(size: CGSize(width: 2048, height: 1536))
//
////        let scene = DrunkFightGameScene(size: CGSize(width: 2048, height: 1536))
//        scene.scaleMode = .aspectFit
//
//        /*
//         If we want to make this game resizable for iPad, we may add init MenuScene in a different way... not sure yet
//         let scene = MenuScene(size: CGSize(width: 2048, height: 1536)
//         */
//        view.ignoresSiblingOrder = true
//        view.showsFPS = true
//        view.showsNodeCount = true
//        view.showsPhysics = true // draw physics bodies so that we can easily see how they behave
//
//        // Present the scene. Navigate to scene that we declared above
//        view.presentScene(scene)
//    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
