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
            view.presentScene(scene)
            view.showsPhysics = false
            self.menuScene = scene
        }
    }

    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

