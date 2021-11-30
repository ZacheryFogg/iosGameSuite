//
//  DrunkFightGameScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/15/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

class TankGameScene: SKScene {
    
    //MARK: - Properties
    
    // Temp vars... until I flesh more stuff out
    let missileRadius: CGFloat = 10
    let boundaryWidth: CGFloat = 10
    let wallWidth: CGFloat = 10
    
    var bottomControlPanel: SKSpriteNode!
    
    // Each player is represented by a tank
    var playerRed: SKSpriteNode!
    var playerBlue: SKSpriteNode!
    
    var powerUp: SKSpriteNode! // TODO: Add multiple powerUp types

    
    var walls: [SKShapeNode] = []
    var missiles: [SKShapeNode] = []
    
    var gameSpeedPerSecond: CGFloat = 100.0 // How fast do objects move
    
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
    

    
    //MARK: - Systems
    override func didMove(to view: SKView) {

//        self.setupNodes()
        
        self.startGame()
        
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
        isGameOver.toggle()
        
        createMissile(positionAt: CGPoint(x:size.width/2, y: size.height/2), withVelocity: CGVector(dx: 100, dy:100))
    }
    
    // Update Game State
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if isGameOver{
            movePlayer(forPlayer: "PlayerRed")
        }
        
        
    }
    
    
}
//MARK: - Configuration

extension TankGameScene {
    // Setup all nodes present in game scene
    func setupNodes(){
        self.removeAllChildren()
        resetPlayers()
        createBottomControlPanel()
        createPlayers()
        
    }
    
    func startGame(){
        // In event of restart we want to start with no children and re add
        self.removeAllChildren()
        setupPhysicsWorld()
        resetPlayers()
        
//        createBottomControlPanel()
        createPlayers()
//        createBackground()
        createBoundaries()
    }
    func setupPhysicsWorld(){
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // No gravity in this world
        self.physicsWorld.contactDelegate = self
    }
    
    func createBoundaries() {
        
        func createVeritcalBoundary(x: CGFloat){
            let boundarySize = CGSize(width: boundaryWidth, height: self.size.height)
            let boundary = SKShapeNode(rectOf: boundarySize)
            boundary.physicsBody = SKPhysicsBody(rectangleOf: boundarySize).ideal().manualMovement()
            
            boundary.position = CGPoint(x: x, y: self.size.height/2.0)
            boundary.strokeColor = .green
            boundary.fillColor = .green
            self.addChild(boundary)
            
        }
        func createHorizontalBoundary(y: CGFloat){
            let boundarySize = CGSize(width: self.size.width, height: boundaryWidth)
            let boundary = SKShapeNode(rectOf: boundarySize)
            boundary.physicsBody = SKPhysicsBody(rectangleOf: boundarySize).ideal().manualMovement()
            
            boundary.position = CGPoint(x: self.frame.width/2.0, y: y)
            print(boundary.position)
            boundary.strokeColor = .green
            boundary.fillColor = .green
            self.addChild(boundary)
        }
        
        createVeritcalBoundary(x: boundaryWidth/2.0)
        createVeritcalBoundary(x: self.size.width - boundaryWidth/2.0)
        
        createHorizontalBoundary(y: boundaryWidth/2.0)
        createHorizontalBoundary(y: self.frame.height - boundaryWidth/2.0)
        
    }
    
    func resetPlayers() {
        
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
        
        // Create and position nodes for players
        playerRed = SKSpriteNode(imageNamed: "playerRed")
        playerRed.name = "PlayerRed"
        playerRed.zPosition = 5.0
        playerRed.setScale(0.5)
        playerRed.position = CGPoint(x: frame.width - playerRed.frame.width/2.0 - 100, y: 0 + playerRed.frame.height/2.0)
        playerRedPosY = playerRed.position.y
        
        playerBlue = SKSpriteNode(imageNamed: "playerBlue")
        playerBlue.name = "PlayerBlue"
        playerBlue.zPosition = 5.0
        playerBlue.setScale(0.5)
        playerBlue.position = CGPoint(x: playerBlue.frame.width/2.0 + 100.0, y: boundaryWidth + playerBlue.frame.height * 2.0)
        playerBluePosY = playerBlue.position.y
        
        // Add physics bodies to players
        playerRed.physicsBody = SKPhysicsBody(rectangleOf: playerRed.size)
        playerRed.physicsBody!.affectedByGravity = false
        playerRed.physicsBody!.restitution = 0.0
        playerRed.physicsBody!.categoryBitMask = PhysicsCategory.Player
        //TODO: Update this for the powerups, bullets, obstables, etc... that will be added
//        playerRed.physicsBody!.contactTestBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Block | PhysicsCategory.Coin
        self.addChild(playerRed)
        print(playerRed.position)
        
        playerBlue.physicsBody = SKPhysicsBody(rectangleOf: playerBlue.size)
        playerBlue.physicsBody!.affectedByGravity = false
        playerBlue.physicsBody!.restitution = 0.0
        playerBlue.physicsBody!.categoryBitMask = PhysicsCategory.Player
        //TODO: Update this for the powerups, bullets, obstables, etc... that will be added
//        playerRed.physicsBody!.contactTestBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Block | PhysicsCategory.Coin
        self.addChild(playerBlue)
        
    }
    
    // This will be an effective wall for the players/bullets... it will have a physics body
    func createBottomControlPanel(){
        bottomControlPanel = SKSpriteNode(imageNamed: "ground")
        bottomControlPanel.name = "BottomControlPanel"
        bottomControlPanel.anchorPoint = .zero
        bottomControlPanel.zPosition = 1.0
        // Set position of each ground to be i x width, so that they are horizontally stacked
        bottomControlPanel.position = CGPoint(x: 0.0, y:0.0)
        
        // Add physics body
        bottomControlPanel.physicsBody = SKPhysicsBody(rectangleOf: bottomControlPanel.size)
        bottomControlPanel.physicsBody!.isDynamic = false
        bottomControlPanel.physicsBody!.affectedByGravity = false
        bottomControlPanel.physicsBody!.categoryBitMask = PhysicsCategory.Boundary
        self.addChild(bottomControlPanel)
    }
    
    // Create Powerups - Spawn them in defined range in middle of map
    func createPowerup(){
        
    }
    
    // Create an individual bullet with a position and a velocity and physics body
    // Many bullets can exist at a time
    // Player should check for collision with any bullet
    
    // May need to store bullets in a vector just like walls...
    func createMissile(positionAt position: CGPoint, withVelocity velocity: CGVector){
        
        let missile = SKShapeNode(circleOfRadius: missileRadius)
        missile.position = position
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missileRadius).ideal()
        missile.physicsBody!.velocity = velocity
        
        // make missile color of player who fired it
        missile.strokeColor = .purple
        missile.fillColor = .purple
        
        self.addChild(missile)
        self.missiles.append(missile)

        
    }
    func createWalls(){
        
    }
    
    //This will likely split into multiple functions
    func movePlayer(forPlayer player: String){
        
        let amountToMove = CGPoint(x: gameSpeedPerSecond * CGFloat(dt), y:0.0)
        enumerateChildNodes(withName: player) { (node, _) in
            let playerToMove = node as! SKSpriteNode
            
            playerToMove.position -= amountToMove
        }
        
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
