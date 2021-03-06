//
//  MenuScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 10/19/21.
//
import SpriteKit

class ButtonNode: SKSpriteNode {} // creating a class for ButtonNode will allow us to type check later... maybe
class MenuScene: SKScene {
    
    //MARK: - Properties
    
    let DemoGame = ButtonNode(imageNamed: "jSONGameIcon")
    let ClayGame = ButtonNode(imageNamed: "puck_icon")
    let TankGame = ButtonNode(imageNamed: "blueTankIcon")
    let SnakeGame = ButtonNode(imageNamed: "snakeGameIcon")
    
    var settingsContainerNode = SKSpriteNode()
    //MARK: - Systems
    override func didMove(to view: SKView) { // didMove() is called as soon as the scene appears on screen
        
        let background = SKSpriteNode(imageNamed: "startMenuBackground")
        background.name = "background"
        background.anchorPoint = .zero
        background.position = CGPoint(x: 0.0, y: 0.0)
        background.zPosition = 1.0 // Make sure is appears behind other children
        self.addChild(background)
        
        let background2 = SKSpriteNode(imageNamed: "startMenuForeground")
        
        
        background2.name = "background2"
        background2.anchorPoint = .zero
        background2.position = CGPoint(x: 0.0, y: 0.0)
        background2.zPosition = 1.0 // Make sure is appears behind other children
        self.addChild(background2)
        
        
        DemoGame.name = "DemoGame"
        ClayGame.name = "ClayGame"
        TankGame.name = "TankGame"
        SnakeGame.name = "SnakeGame"
        
        DemoGame.setScale(0.4375)
        ClayGame.setScale(0.5)
        TankGame.setScale(0.5)
        SnakeGame.setScale(0.5)
        
        DemoGame.zPosition = 3.0
        ClayGame.zPosition = 3.0
        TankGame.zPosition = 3.0
        SnakeGame.zPosition = 3.0
        
        
        let frameW = frame.width
        let frameH = frame.height
        
        let ButtonNodes = [DemoGame, ClayGame, TankGame, SnakeGame]
                
        let xs = [frameW * (1/5), frameW * (2/5), frameW * (3/5), frameW * (4/5)].map {Int($0)}
        
        var i = 0
        for x in xs{
            let node = ButtonNodes[i]
            node.position = CGPoint(x: x, y: Int(frameH/3.0) + 12)
            self.addChild(node)
            i+=1
            
        }
    }
    
    override func touchesBegan(_ touches : Set<UITouch>, with event: UIEvent?){
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {return}
        
        // Clicking on the button will transition to next game scene
        let node = self.atPoint(touch.location(in: self))
                
        var gameScene: SKScene
        
        // Switch to determine which scene to display
        switch node.name {
            
        case DemoGame.name:
            gameScene = InfiniteJSONScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
        case ClayGame.name:
            gameScene = SKScene(fileNamed: "AHGameScene")!
            gameScene.scaleMode = .aspectFill
        case TankGame.name:
            gameScene = TankGameScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
        case SnakeGame.name:
            gameScene = SnakeGameScene(size: CGSize(width: self.size.width * 3, height: self.size.height * 3))
        default:
            return
        }
        self.view?.presentScene(gameScene, transition: .doorsOpenVertical(withDuration: 0.5))
        
        
    }
}
