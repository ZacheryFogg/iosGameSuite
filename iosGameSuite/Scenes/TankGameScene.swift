//
//  DrunkFightGameScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/15/21.
//

import SpriteKit
import GameplayKit

class TankGameScene: SKScene {
    
    //MARK: - Properties
    
    // Each player is represented by a tank
    var playerRed: SKSpriteNode!
    var playerBlue: SKSpriteNode!
    
    var powerUp: SKSpriteNode! // TODO: Add multiple powerUp types

    
    var walls: [SKSpriteNode] = []
    
    var gameSpeedPerSecond: CGFloat = 800.0 // How fast do objects move
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var playerRedVelocityY: CGFloat = 0.0
    var playerRedVelocityX: CGFloat = 0.0
    
    var playerBlueVelocityY: CGFloat = 0.0
    var playerBlueVelocityX: CGFloat = 0.0
    
    var playerRedPosY: CGFloat = 0.0
    var playerRedPosX: CGFloat = 0.0
    
    var playerBluePosY: CGFloat = 0.0
    var playerBluePosX: CGFloat = 0.0
    
    var startingPlayerLives: Int = 3

    var playerRedLives: Int = 3
    var playerBlueLives: Int = 3
    
    var isGameOver = false

    // Evaluate need for these later
    var pauseButtonNode: SKSpriteNode!
    var pauseContainerNode = SKNode()
    
    var postGameContainerNode = SKNode()
    
    // Names for nodes declared globally so that they can be easily changed
    let pauseButtonNodeName: String = "pauseButtonNode"
    let resumeButtonNodeName: String = "resumeButtonNode"
    let quitFromPauseButtonNodeName: String = "quitFromPauseButtonNode"
    let quitFromPostButtonNodeName: String = "quitFromPostButtonNode"
    let replayButtonNodeName: String = "replayButtonNode"
    
    var playableRect: CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height {
        
        case 2688,1792,2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        
        let playableHeight = self.size.width / ratio
        let playableMargin = (self.size.height - playableHeight) / 2.0
        return CGRect(x: 0.0, y: playableMargin, width: self.size.width, height: playableHeight)
    }
    
    //MARK: - Systems
    override func didMove(to view: SKView) {

        self.setupNodes()
        
    }
    
    // Handle Each Players Controls
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let node = atPoint(touch.location(in: self))
    }
    
    // Handle When A Touch has ended (this could be for the tank to stop moving, turning, etc...
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
    }
    
    // Update Game State
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    
}
//MARK: - Configuration

extension TankGameScene {
    // Setup all nodes present in game scene
    func setupNodes(){}
    
    func setupPhysics(){
        physicsWorld.contactDelegate = self
    }
    
    func createBackground(){
        let background = SKSpriteNode(imageNamed: "background")
        background.name = "Background"
        // Default anchor point of a node is in center of screen (.5,.5), we need it to be bottom left (0,0)
        background.anchorPoint = .zero
        background.position = CGPoint(x: 0.0, y: 0.0)
        background.zPosition = -1.0 // Make sure is appears behind other children
        self.addChild(background)
    }
    
    // Create player nodes and add physics bodies to them
    func createPlayers(){
        
    }
    
    // Create Powerups - Spawn them in defined range in middle of map
    func createPowerup(){
        
    }
    
    // Create an individual bullet with a position and a velocity and physics body
    // Many bullets can exist at a time
    // Player should check for collision with any bullet
    func createBullet(){
        
    }
    func createWalls(){
        
    }
    
    //This will likely split into multiple functions
    func movePlayer(){
        
    }
    
    func setupScore(){
        
    }
    
    func setupPauseButton(){
        
    }
    
    func createPausePanel(){
        
    }
    
    func createPostGamePanel(){
        
    }
    
    func decrementPlayerLife(){
        
    }
   
}
//MARK: - SKPhysicsContactDelegate
extension TankGameScene: SKPhysicsContactDelegate {
    
    // Handle collisions for each player and bullets and respond appropriately... maybe bullets will just bounce appropriately if no gravity?
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        
    }
    
}
