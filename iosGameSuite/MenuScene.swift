//
//  MenuScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 10/19/21.
//

import SpriteKit

class ButtonNode: SKSpriteNode {} // creating a class for ButtonNode will allow us to type check later... maybe

class MenuScene: SKScene {
    let gameTitleLabel = SKLabelNode(fontNamed: "American Typewriter")
    
    let ClayGame1 = ButtonNode(imageNamed: "cowboy")
    let ClayGame2 = ButtonNode(imageNamed: "cowboy")
    let ZachGame1 = ButtonNode(imageNamed: "cowboy")
    let ZachGame2 = ButtonNode(imageNamed: "cowboy")
    let LilKGame1 = ButtonNode(imageNamed: "log")
    let LilKGame2 = ButtonNode(imageNamed: "cowboy")
    
    override func didMove(to view: SKView) { // didMove() is called as soon as the scene appears on screen
        
        // Configure Title
        gameTitleLabel.text = "Title of Game"
        gameTitleLabel.fontSize = 35
        gameTitleLabel.fontColor = SKColor.cyan
        gameTitleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        self.addChild(gameTitleLabel)
        
        // Create 2 rows of 3 columns of button nodes
        
//        let button = ButtonNode(imageNamed: "DefaultGameIcon") // create throwaway button to calculate height and width
//        let buttonW = button.frame.width
//        let buttonH = button.frame.height
        
        ClayGame1.name = "ClayGame1"
        ClayGame2.name = "ClayGame2"
        ZachGame1.name = "ZachGame1"
        ZachGame2.name = "ZachGame2"
        LilKGame1.name = "LilKGame1"
        LilKGame2.name = "LilKGame2"

        
        let frameW = frame.width
        let frameH = frame.height
        
        
        
        let ButtonNodes = [ClayGame1, ClayGame2, ZachGame1, ZachGame2, LilKGame1, LilKGame2]
        
        let bottomRowTopMargin: Int = 10
        
        let xs = [frameW * (1/4), frameW * (2/4), frameW * (3/4)].map {Int($0)}
        let ys = [frameH * (1/3), frameH * (2/3)].map {Int($0) - bottomRowTopMargin }
        
        var i = 0
        for x in xs{
            for y in ys{
                let node = ButtonNodes[i]
                node.position = CGPoint(x: x, y: y)
                self.addChild(node)
                i+=1
            }
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
            if let view = view{
                let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
                
                var gameScene: SKScene
                switch node.name! {
                case ClayGame1.name!:
                    gameScene = InfiniteJSONScene(size: self.size)
                case ClayGame2.name!:
                    gameScene = InfiniteJSONScene(size: self.size)
                case ZachGame1.name!:
                    gameScene = InfiniteJSONScene(size: self.size)
                case ZachGame1.name!:
                    gameScene = InfiniteJSONScene(size: self.size)
                case LilKGame1.name!:
                    gameScene = InfiniteJSONScene(size: self.size)
                case LilKGame2.name!:
                    let temp = PostGameScene(size: self.size)
                    temp.passGameInfo(from: InfiniteJSONScene(size: self.size), redScore: 2, blueScore: 5)
                    gameScene = temp
                default:
                    gameScene = InfiniteJSONScene(size: self.size)
                }
                self.view?.presentScene(gameScene, transition: transition)
            }
        }

    }
    
    
}
