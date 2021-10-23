//
//  PostGameScene.swift
//  iosGameSuite
//
//  Created by Kevin Veronneau on 10/22/21.
//

import SpriteKit

class PostGameScene: SKScene {
    // info from the game that was played
    var winner = "Nobody"
    var redScore = 0, blueScore = 0
    var sceneSender: SKScene?

    
    let winnerLabel = SKLabelNode(fontNamed: "American Typewriter")
    let scoreLabel = SKLabelNode(fontNamed: "American Typewriter")
    
    let PlayAgain = ButtonNode(imageNamed: "PlayAgain")
    let MainMenu = ButtonNode(imageNamed: "MainMenu")
    
    override func didMove(to view: SKView) { // didMove() is called as soon as the scene appears on screen
        
        let frameW = frame.width
        let frameH = frame.height
        
        // Configure Title
        winnerLabel.text = "Game Over \(self.winner) Wins"
        winnerLabel.fontSize = 35
        winnerLabel.fontColor = SKColor.cyan
        winnerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        self.addChild(winnerLabel)
        
        scoreLabel.text = "\(self.redScore) - \(self.blueScore)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.cyan
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 150)
        self.addChild(scoreLabel)
        
        // Stack the two buttons
        
        PlayAgain.name = "PlayAgain"
        MainMenu.name = "MainMenu"
        
        let ButtonNodes = [PlayAgain, MainMenu]
        
        let bottomRowTopMargin: Int = 10
        let x = Int(frameW / 2)
        let ys = [frameH * (1/2), frameH * (1/3)].map {Int($0) - bottomRowTopMargin }
        
        var i = 0
        for y in ys{
            let node = ButtonNodes[i]
            node.position = CGPoint(x: x, y: y)
            self.addChild(node)
            i+=1
        }
    }
    
    override func touchesBegan(_ touches : Set<UITouch>, with event: UIEvent?){
        // Clicking on the button will transition to next game scene
        if let touch = touches.first {
            let pos = touch.location(in: self)
//            let node = self.atPoint(pos)
//            guard let node = nodes(at: position).first(where: {$0 is ButtonNode}) as? ButtonNode else {return}
            let node = self.atPoint(pos)
            // Switch to determine which scene to display
            if let view = view {
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                
                var gameScene: SKScene
                switch node.name! {
                case PlayAgain.name!:
                    if sceneSender != nil {
                        gameScene = sceneSender!
                    } else {
                        gameScene = MenuScene(size: self.size)
                    }
                case MainMenu.name!:
                    gameScene = MenuScene(size: self.size)
                default:
                    gameScene = InfiniteJSONScene(size: self.size)
                }
                self.view?.presentScene(gameScene, transition: transition)
            }
        }

    }
    
    func passGameInfo(from game: SKScene, redScore: Int, blueScore: Int) {
        self.sceneSender = game
        self.redScore = redScore
        self.blueScore = blueScore
        if blueScore > redScore {
            self.winner = "Blue"
        } else if redScore > blueScore {
            self.winner = "Red"
        } else {
            self.winner = "Nobody"
        }
    }

    
}

