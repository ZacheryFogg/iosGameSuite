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
    let gameTitleLabel = SKLabelNode(fontNamed: "American Typewriter")
    
    let DemoGame = ButtonNode(imageNamed: "ninja")
    let ClayGame = ButtonNode(imageNamed: "cowboy")
    let TankGame = ButtonNode(imageNamed: "tankIcon")
    let SnakeGame = ButtonNode(imageNamed: "snakeGameIcon")
    
    var settingsContainerNode = SKSpriteNode()
    //MARK: - Systems
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
        
        DemoGame.name = "DemoGame"
        ClayGame.name = "ClayGame"
        TankGame.name = "TankGame"
        SnakeGame.name = "SnakeGame"
        
        DemoGame.setScale(0.5)
        ClayGame.setScale(0.5)
        TankGame.setScale(0.5)
        SnakeGame.setScale(0.5)

        
        let frameW = frame.width
        let frameH = frame.height
        
        let ButtonNodes = [DemoGame, ClayGame, TankGame, SnakeGame]
                
        let xs = [frameW * (1/5), frameW * (2/5), frameW * (3/5), frameW * (4/5)].map {Int($0)}
        
        var i = 0
        for x in xs{
            let node = ButtonNodes[i]
            node.position = CGPoint(x: x, y: Int(frameH/2.0))
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
//            gameScene = DrunkFightGameScene(size: CGSize(width: 2048, height: 1536))
            gameScene = DrunkFightGameScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
        case ClayGame.name:
            gameScene = InfiniteJSONScene(size: self.size)
        case TankGame.name:
            gameScene = TankGameScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
        case SnakeGame.name:
            gameScene = SnakeGameScene(size: CGSize(width: self.size.width * 3, height: self.size.height * 3))
        default:
            return
        }
//        gameScene.scaleMode = self.scaleMode
        self.view?.presentScene(gameScene, transition: .doorsOpenVertical(withDuration: 0.5))
        
        
    }
    
    func setupSettingsContainer(){
        settingsContainerNode = SKSpriteNode()
        settingsContainerNode.name = "container"
        settingsContainerNode.zPosition = 15.0
        settingsContainerNode.color = UIColor(white: 0.5, alpha: 0.5)
        settingsContainerNode.size = self.size
        settingsContainerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(settingsContainerNode)
        
    }
    
    func setupSetting() {
        setupSettingsContainer()
        
        let settingsPanel = SKSpriteNode(imageNamed: "panel")
        settingsPanel.setScale(1.5)
        settingsPanel.zPosition = 20.0
        settingsPanel.position = .zero
        settingsContainerNode.addChild(settingsPanel)
        
        let musicButton = SKSpriteNode(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
        musicButton.name = "music"
        musicButton.setScale(0.7)
        musicButton.zPosition = 25.0
        musicButton.position = CGPoint(x: -musicButton.frame.width - 50.0, y: 0.0)
        settingsContainerNode.addChild(musicButton)
        
        let effectButton = SKSpriteNode(imageNamed: effectEnabled ? "effectOn" : "effectOff")
        effectButton.name = "effect"
        effectButton.setScale(0.7)
        effectButton.zPosition = 25.0
        effectButton.position = CGPoint(x: musicButton.frame.width + 50.0, y: 0.0)
        settingsPanel.addChild(effectButton)
    }
}

//MARK: - Configuration

//extension GameScene {
//
//}
