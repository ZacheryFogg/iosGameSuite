//
//  DrunkFightGameScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/15/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

class playerNode : SKSpriteNode {
    
    var lives: Int!
    var canFire: Bool!
    var velocityMultiplier: CGFloat!
    init(imageNamed: String, lives: Int, velocity: CGFloat) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .black, size: texture.size())
        
        self.lives = lives
        self.velocityMultiplier = velocity
        self.canFire = true
    }
    
    func decrementLives(){
        self.lives = self.lives - 1
    }
    
    func incrementLives(){
        self.lives = self.lives + 1
    }
    required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
}

class missileNode : SKSpriteNode{
    
    var remainingCollisions: Int!
    var velocity: CGFloat!
    
    init(imageNamed: String, maxCollisions: Int, velocity: CGFloat) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .black, size: texture.size())
        
        self.remainingCollisions = maxCollisions
        self.velocity = velocity
    }
    
    func collide(){
        self.remainingCollisions = self.remainingCollisions - 1
    }
    required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
}

class TankGameScene: SKScene {
    
    //MARK: - Properties
    
    lazy var analogJoystickBlue: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 75, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jSubstrate")))
        js.position = CGPoint(x: 0 + js.radius + boundaryWidth + 20 , y: 0 + js.radius + 20)
        js.zPosition = 30.0
        return js
    }()
    
    lazy var analogJoystickRed: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 75, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jSubstrate")))
        js.position = CGPoint(x: frame.width - boundaryWidth - js.radius - 20 , y: 0 + js.radius + 20)
        js.zPosition = 30.0
        return js
    }()
    
    // Temp vars... until I flesh more stuff out
    let missileRadius: CGFloat = 5
    let boundaryWidth: CGFloat = 5
    let wallWidth: CGFloat = 10
    
    let bottomControlPanelHeight: CGFloat = 70.0
    var bottomControlPanel: SKSpriteNode!
    
    // Each player is represented by a tank
    var playerRed: playerNode!
    var playerBlue: playerNode!
    
    let defaultMissileLaunchCooldown: CGFloat = 5.0
    
    var redScoreNode: SKLabelNode!
    var blueScoreNode: SKLabelNode!
    
    var redCooldownNode : SKSpriteNode!
    var blueCooldownNode: SKSpriteNode!
    
    var redLaunchButton: SKSpriteNode!
    var blueLaunchButton: SKSpriteNode!
    
    var powerUp: SKSpriteNode! // TODO: Add multiple powerUp types

    
    var walls: [SKShapeNode] = []
    
    var missiles: [missileNode] = []
    let missileStandardMaxCollisions: Int = 4
    
    var gameSpeedPerSecond: CGFloat = 100.0 // How fast do objects move
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0

    let playerStartLives: Int = 3
    let startPlayerVelocityMultiplier: CGFloat = 0.05
    
    var isGameOver = false
    
    var imminentReset = false
    
    // Evaluate need for these later
    var pauseButtonNode: SKSpriteNode!
    
    var pauseContainerNode = SKNode()
    var postGameContainerNode = SKNode()
    
    // Names for nodes declared globally so that they can be easily changed
    let pauseButtonNodeName: String = "pauseButtonNode"
    let resumeButtonNodeName: String = "resumeButtonNode"
    
    let quitButtonNodeName: String = "quitButtonNode"
    
    let replayButtonNodeName: String = "replayButtonNode"
    
    let redLaunchMissileButtonNodeName = "redLaunchMissileButton"
    let blueLaunchMissileButtonNodeName = "blueLaunchMissileButton"
    
    let redCooldownNodeName = "redCooldownNode"
    let blueCooldownNodeName = "blueCooldownNode"
    
    var playerRedCooldown: CGFloat = 0.0

    //MARK: - Systems
    override func didMove(to view: SKView) {
        self.startGame()
        
    }
    
    // Handle Each Players Controls
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

    
    }
    
    // Handle When A Touch has ended (this could be for the tank to stop moving, turning, etc...
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let view = self.view else { return }
        
        for touch in touches {
            let node = atPoint(touch.location(in: self))
            
            if node.name == pauseButtonNodeName {
                print("Pause Menu")
                if isPaused { return }
                createPausePanel()
                lastUpdateTime = 0.0
                dt = 0.0
                isPaused = true
                
            } else if node.name == resumeButtonNodeName {
                pauseContainerNode.removeFromParent()
                isPaused = false
                print(isPaused)
            
            } else if node.name == quitButtonNodeName {
                
                let menuScene: SKScene = MenuScene(size: self.size)
                menuScene.scaleMode = self.scaleMode
                
                self.view?.presentScene(menuScene, transition: .doorsCloseVertical(withDuration: 0.5))
            
            } else if node.name == replayButtonNodeName {
                //TODO: Comeback and see if this is the most optimal
                let newGameScene = TankGameScene(size: self.size)
                newGameScene.scaleMode = self.scaleMode
                self.view?.presentScene(newGameScene, transition: .doorsOpenVertical(withDuration: 0.5))
            
            } else if node.name == blueLaunchMissileButtonNodeName && !imminentReset && playerBlue.canFire{
                //TODO: Add cooldown timer
                let rad = playerBlue.zRotation + Double.pi/2
                let pos = CGPoint(x:  playerBlue.position.x + ((missileRadius * 7.5) * cos(rad)), y: playerBlue.position.y + ((missileRadius*7.5) * sin(rad)))
                createMissile(positionAt: pos, withVelocity: CGVector(dx: cos(rad) * 200, dy:sin(rad)*200))
                
                self.handleMissileLaunchCooldown(player: playerBlue, cooldownTime: defaultMissileLaunchCooldown)
                
            } else if node.name == redLaunchMissileButtonNodeName && !imminentReset && playerRed.canFire{
                let rad = playerRed.zRotation + Double.pi/2
                let pos = CGPoint(x:  playerRed.position.x + ((missileRadius*9.0) * cos(rad)), y: playerRed.position.y + ((missileRadius*9.0) * sin(rad)))
                createMissile(positionAt: pos, withVelocity: CGVector(dx: cos(rad) * 200, dy:sin(rad)*200))
                
//                self.handleMissileLaunchCooldown(player: playerRed, cooldownTime: defaultMissileLaunchCooldown)
                playerRedCooldown = defaultMissileLaunchCooldown
            }
            
        }
    }
    
    // Update Game State
    override func update(_ currentTime: TimeInterval) {
        
        if playerRedCooldown > 0.0{
            playerRed.canFire = false
            playerRedCooldown -= CGFloat(dt)
        } else {
            playerRed.canFire = true
            playerRedCooldown = 0.0
        }
        
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
//        print("LT: \(lastUpdateTime)    CT: \(currentTime)   DT: \(dt) ")
        lastUpdateTime = currentTime
        
        if isGameOver {
            // Present out game over scene, with possibly
            if !isPaused{
                createPostGamePanel()
                isPaused = true
            }
        
        } else {
            
            redScoreNode.text = "\(playerRed.lives!)"
            blueScoreNode.text = "\(playerBlue.lives!)"
            
        
            for (index, missile) in missiles.enumerated() {
                
                if (missile.remainingCollisions < 1){
                        missile.removeFromParent()
                    self.createExplosion(position: missile.position, scale: 1.0, timePerFrame: 0.08)
                    missiles.remove(at: index)
                }
                else if (missile.physicsBody!.velocity.speed() > 0.01){
                    missile.zRotation = missile.physicsBody!.velocity.angle() - Double.pi / 2
                }
                
            }
        }
    }
    
    
}
//MARK: - Configuration

extension TankGameScene {

    func handleMissileLaunchCooldown(player: playerNode, cooldownTime: CGFloat){
        player.canFire = false
        self.run(.sequence([
            .wait(forDuration: cooldownTime),
            .run{[weak self] in
                player.canFire = true
        }]))
    }
    func startGame(){
        // In event of restart we want to start with no children and re add
        self.removeAllChildren()
        setupPhysicsWorld()
        
        createBottomControlPanel()
        createPauseButton()
        createPlayers()
        createBackground()
        createBoundaries()
        createWalls()


    }
    
    func checkEndgameConditions(){
        if playerRed.lives! < 1 || playerBlue.lives! < 1{
            isGameOver = true
        }
    }
    func setupJoysticks(){
        addChild(analogJoystickBlue)
        addChild(analogJoystickRed)
        
        analogJoystickRed.trackingHandler = { [unowned self] data in
            if !self.imminentReset && (data.velocity.y != 0.0 && data.velocity.x != 0.0){
                self.playerRed.position = CGPoint(x: self.playerRed.position.x + (data.velocity.x * playerRed.velocityMultiplier),
                                           y: self.playerRed.position.y + (data.velocity.y * playerRed.velocityMultiplier))
                self.playerRed.zRotation = data.angular
                }
        }
        
        analogJoystickBlue.trackingHandler = { [unowned self] data in
            if !self.imminentReset && (data.velocity.y != 0.0 && data.velocity.x != 0.0){
                self.playerBlue.position = CGPoint(x: self.playerBlue.position.x + (data.velocity.x * playerBlue.velocityMultiplier),
                                           y: self.playerBlue.position.y + (data.velocity.y * playerBlue.velocityMultiplier))
                self.playerBlue.zRotation = data.angular
            }
        }

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
            boundary.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Boundary

            
            boundary.position = CGPoint(x: x, y: self.size.height/2.0)
            boundary.strokeColor = .black
            boundary.fillColor = .white

            self.addChild(boundary)
            
        }
        func createHorizontalBoundary(y: CGFloat){
            let boundarySize = CGSize(width: self.size.width, height: boundaryWidth)
            let boundary = SKShapeNode(rectOf: boundarySize)
            boundary.physicsBody = SKPhysicsBody(rectangleOf: boundarySize).ideal().manualMovement()
            boundary.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Boundary

            
            boundary.position = CGPoint(x: self.frame.width/2.0, y: y)
            boundary.strokeColor = .black
            boundary.fillColor = .white
            self.addChild(boundary)
        }
        
        createVeritcalBoundary(x: boundaryWidth/2.0)
        createVeritcalBoundary(x: self.size.width - boundaryWidth/2.0)
        
        createHorizontalBoundary(y: self.bottomControlPanel.frame.height + boundaryWidth/2.0)
        createHorizontalBoundary(y: self.frame.height - boundaryWidth/2.0)
        
    }
    //TODO: Add some random generation to walls
    func createWalls(){
        
        func createWall(position: CGPoint, size: CGSize){
            let wall = SKShapeNode(rectOf: size)
            wall.physicsBody = SKPhysicsBody(rectangleOf: size).ideal().manualMovement()
            
            wall.position = position
            wall.strokeColor = .black
            wall.fillColor = .white
            wall.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Boundary

            self.addChild(wall)
        }
//        let wallPositions: [CGPoint] = [CGPoint()]
        createWall(position: CGPoint(x: self.size.width/4.0, y: (self.size.height/3.0) * 2), size: CGSize(width: 10.0, height: 70))
        createWall(position: CGPoint(x: self.size.width/4.0 + 20, y: (self.size.height/3.0) * 2 + 40), size: CGSize(width: 50.0, height: 10))
        
        createWall(position: CGPoint(x: (self.size.width/4.0) * 3, y: self.size.height/2.0), size: CGSize(width: 10.0, height: 70))
        createWall(position: CGPoint(x: (self.size.width/4.0) * 3 - 20, y: (self.size.height/2.0) - 40), size: CGSize(width: 50.0, height: 10))
        
        
        
    }
    
    func createBackground(){
        let background = SKSpriteNode(imageNamed: "altBackground2")
        background.name = "Background"
        // Default anchor point of a node is in center of screen (.5,.5), we need it to be bottom left (0,0)
        background.anchorPoint = .zero
        background.position = CGPoint(x: 0.0, y: 0.0)
        background.zPosition = -1.0 // Make sure is appears behind other children
        self.addChild(background)
    }
    
    // Create player nodes and add physics bodies to them
    func createPlayers(){
        
        let startPositionOffset = 5.0 +  boundaryWidth
        let playerScaleFactor = 0.5
        
        // Red Player
        
        // Create and position
        playerRed = playerNode(imageNamed: "redTank", lives: playerStartLives, velocity: startPlayerVelocityMultiplier)
        playerRed.name = "PlayerRed"
        playerRed.zPosition = 5.0
        playerRed.setScale(playerScaleFactor)
        playerRed.position = CGPoint(x: frame.width - (playerRed.frame.width/2.0) - startPositionOffset, y: self.frame.height - (playerRed.frame.height/2.0) - startPositionOffset)
        
        // Set to face downwards originally
        playerRed.zRotation = 3.14
        
        // Add physics body
        let redScaledSize = CGSize(width: playerRed.texture!.size().width * playerScaleFactor, height: playerRed.texture!.size().height * playerScaleFactor)
        playerRed.physicsBody = SKPhysicsBody(texture: playerRed.texture!, size: redScaledSize)
        playerRed.physicsBody!.affectedByGravity = false
        playerRed.physicsBody!.restitution = 0.0
        playerRed.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Player
        playerRed.physicsBody!.contactTestBitMask = TankGamePhysicsCategory.Missile | TankGamePhysicsCategory.Powerup
        self.addChild(playerRed)
        
        // Blue Player
        
        // Create and position
        playerBlue = playerNode(imageNamed: "blueTank", lives: playerStartLives, velocity: startPlayerVelocityMultiplier)
        playerBlue.name = "PlayerBlue"
        playerBlue.zPosition = 5.0
        playerBlue.zRotation = 0.0
        playerBlue.setScale(playerScaleFactor)
        playerBlue.position = CGPoint(x: playerBlue.frame.width/2.0 + startPositionOffset, y: self.bottomControlPanelHeight +  playerBlue.frame.height/2.0 + startPositionOffset)
        
        // Add physics body
        let blueScaledSize = CGSize(width: playerBlue.texture!.size().width * playerScaleFactor, height: playerBlue.texture!.size().height * playerScaleFactor)
        playerBlue.physicsBody = SKPhysicsBody(texture: playerBlue.texture!, size: blueScaledSize)
        playerBlue.physicsBody!.affectedByGravity = false
        playerBlue.physicsBody!.restitution = 0.0
        playerBlue.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Player
        playerBlue.physicsBody!.contactTestBitMask = TankGamePhysicsCategory.Missile | TankGamePhysicsCategory.Powerup
        self.addChild(playerBlue)
        
        // Animate Players
//        var redTextures: [SKTexture] = []
//        for i in 1...9 {
//            redTextures.append(SKTexture(imageNamed: "redTank\(i)"))
//        }
//        playerRed.run(.repeatForever(.animate(with: redTextures, timePerFrame: 0.043)))
        
//        var blueTextures: [SKTexture] = []
//        for i in 1...9 {
//            blueTextures.append(SKTexture(imageNamed: "blueTank\(i)"))
//        }
//        playerBlue.run(.repeatForever(.animate(with: blueTextures, timePerFrame: 0.043)))
        
    }
    
    // This will be an effective wall for the players/bullets... it will have a physics body
    func createBottomControlPanel(){
        bottomControlPanel = SKSpriteNode(color: .white, size: CGSize(width: self.frame.width, height: bottomControlPanelHeight))
        bottomControlPanel.name = "BottomControlPanel"
        bottomControlPanel.anchorPoint = .zero
        bottomControlPanel.zPosition = 1.0
        // Set position of each ground to be i x width, so that they are horizontally stacked
        bottomControlPanel.position = CGPoint(x: 0.0, y:0.0)
    
        self.addChild(bottomControlPanel)
        
        setupJoysticks()
        setupLaunchButtonsAndCooldown()
        createScoreboard()
    }
    
    func setupLaunchButtonsAndCooldown() {
        let offsetFromJoystick = 10.0
//        redLaunchButton = SKSpriteNode(imageNamed: "bluePlayerLaunchButton")
        redLaunchButton = SKSpriteNode(color: .red, size: CGSize(width: 60.0, height: 40.0))
        redLaunchButton.name = redLaunchMissileButtonNodeName
        redLaunchButton.zPosition = 2.0
        redLaunchButton.position = CGPoint(x: analogJoystickRed.position.x - redLaunchButton.frame.width  - offsetFromJoystick ,y: analogJoystickRed.position.y)
        
        addChild(redLaunchButton)
        
        blueLaunchButton = SKSpriteNode(color: .blue, size: CGSize(width: 60.0, height: 40.0))
        blueLaunchButton.name = blueLaunchMissileButtonNodeName
        blueLaunchButton.zPosition = 2.0
        blueLaunchButton.position = CGPoint(x: analogJoystickBlue.position.x + blueLaunchButton.frame.width + offsetFromJoystick ,y: analogJoystickBlue.position.y)
        
        addChild(blueLaunchButton)
        
        redCooldownNode = SKSpriteNode(color: .red, size: CGSize(width: 10.0, height: 40.0))
        redCooldownNode.name = redCooldownNodeName
        redCooldownNode.zPosition = 3.0
        redCooldownNode.position = CGPoint(x: redLaunchButton.position.x - redLaunchButton.frame.width/2.0 - redCooldownNode.frame.width * 2.0, y: redLaunchButton.position.y)
        
        addChild(redCooldownNode)
        
    }
    // Create Powerups - Spawn them in defined range in middle of map
    func createPowerup(){
        
    }
    
    // Create an individual bullet with a position and a velocity and physics body
    // Many bullets can exist at a time
    // Player should check for collision with any bullet
    
    // May need to store bullets in a vector just like walls...
    func createMissile(positionAt position: CGPoint, withVelocity velocity: CGVector){
        
        //TODO: Comeback and handle velocity
        let missile = missileNode(imageNamed: "missile1", maxCollisions: self.missileStandardMaxCollisions, velocity: 0.0)
//        let missile = missileNode(imageNamed: "JSON1", maxCollisions: self.missileStandardMaxCollisions, velocity: 0.0)

        missile.position = position
        missile.setScale(1.0)
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missileRadius).ideal()
        missile.physicsBody!.velocity = velocity
        missile.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Missile
        missile.physicsBody!.contactTestBitMask = TankGamePhysicsCategory.Missile | TankGamePhysicsCategory.Player | TankGamePhysicsCategory.Boundary

        
        self.addChild(missile)
        self.missiles.append(missile)
                
        var missileTextures: [SKTexture] = []
        for i in 1...9 {
            missileTextures.append(SKTexture(imageNamed: "missile\(i)"))
        }
//        for i in 1...3 {
//            missileTextures.append(SKTexture(imageNamed: "JSON_Missile\(i)"))
//        }
        missile.run(.repeatForever(.animate(with: missileTextures, timePerFrame: 0.08)))
        
    }
    
    //This will likely split into multiple functions
//    func movePlayer(forPlayer player: String){
//
//        enumerateChildNodes(withName: player) { (node, _) in
//            let playerToMove = node as! SKSpriteNode
//
//            let rad = playerToMove.zRotation + Double.pi/2
//            let amountToMove = CGPoint(x: (self.gameSpeedPerSecond * CGFloat(self.dt)) * cos(rad), y: (self.gameSpeedPerSecond * CGFloat(self.dt) * sin(rad)))
//
//            playerToMove.position += amountToMove
//        }
//
//    }
    
    func createScoreboard(){
        let middleOffset = 30.0
        redScoreNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        redScoreNode.text = "\(playerStartLives)"
        redScoreNode.fontSize = 20.0
        redScoreNode.fontColor = .red
        redScoreNode.horizontalAlignmentMode = .center
        redScoreNode.zPosition = 5.0
        redScoreNode.position = CGPoint(x: bottomControlPanel.frame.width/2.0 + redScoreNode.frame.width + middleOffset, y: bottomControlPanel.frame.height/2.0)
        
        self.addChild(redScoreNode)
        
        blueScoreNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        blueScoreNode.text = "\(playerStartLives)"
        blueScoreNode.fontSize = 20.0
        blueScoreNode.fontColor = .blue
        blueScoreNode.horizontalAlignmentMode = .center
        blueScoreNode.zPosition = 5.0
        blueScoreNode.position = CGPoint(x: bottomControlPanel.frame.width/2.0 - blueScoreNode.frame.width - middleOffset, y: bottomControlPanel.frame.height/2.0)
        
        self.addChild(blueScoreNode)
        
        let dashNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        dashNode.text = "-"
        dashNode.fontSize = 20.0
        dashNode.horizontalAlignmentMode = .center
        dashNode.verticalAlignmentMode = .top
        dashNode.zPosition = 5.0
        dashNode.fontColor = .black
        dashNode.position = CGPoint(x: bottomControlPanel.frame.width/2.0 , y: bottomControlPanel.frame.height/2.0)
        
        self.addChild(dashNode)
        
        
    
        
        
    }
    
    func createPauseButton(){
        pauseButtonNode = SKSpriteNode(imageNamed: "pause")
        pauseButtonNode.setScale(0.2)
        pauseButtonNode.zPosition = 50.0
        pauseButtonNode.name = pauseButtonNodeName
        pauseButtonNode.position = CGPoint(x: 0.0 + pauseButtonNode.frame.width/2 + 10.0, y: self.frame.maxY - pauseButtonNode.frame.height/2 - 10.0)
        self.addChild(pauseButtonNode)
    }
    
    func createPausePanel(){
        let menuScale = 0.2
        
        pauseContainerNode.position  = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2.0 + bottomControlPanelHeight/2.0)
        self.addChild(pauseContainerNode)
        
        // Image will need to change for all of these
        let pauseGamePanel = SKSpriteNode(color: .darkGray, size: CGSize(width: self.frame.width/2.0, height: self.frame.width/4.0))
        pauseGamePanel.zPosition = 60.0
        pauseContainerNode.addChild(pauseGamePanel)
        
        let pauseGamePanelTitle = SKLabelNode(fontNamed: "AmericanTypewriter")
        pauseGamePanelTitle.text = "Game Paused" // this logic is filler, need two player scores
        pauseGamePanelTitle.zPosition = 80.0
        pauseGamePanelTitle.fontSize = 30
        pauseGamePanelTitle.fontColor = SKColor.white
    
        pauseGamePanelTitle.position = CGPoint(x: pauseGamePanel.frame.midX, y: pauseGamePanel.frame.maxY - 50.0)
        pauseGamePanel.addChild(pauseGamePanelTitle)
        

        let replayButton = SKSpriteNode(imageNamed: "resume")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(menuScale)
        replayButton.position = CGPoint(x: pauseGamePanel.frame.midX - replayButton.frame.width, y:pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(replayButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitButtonNodeName
        quitButton.setScale(menuScale)
        quitButton.position = CGPoint(x: pauseGamePanel.frame.midX + quitButton.frame.width , y: pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(quitButton)
        
        //TODO: Replace this obviously
        let resumeButton = SKSpriteNode(imageNamed: "back")
        resumeButton.zRotation = 3.14
        resumeButton.zPosition = 70.0
        resumeButton.name = resumeButtonNodeName
        resumeButton.setScale(menuScale)
        resumeButton.position = CGPoint(x: pauseGamePanel.frame.midX , y: pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(resumeButton)
    }
    
    func createPostGamePanel(){
        let menuScale = 0.2
        
        postGameContainerNode.position  = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2.0 + bottomControlPanelHeight/2.0)
        self.addChild(postGameContainerNode)
        
        // Image will need to change for all of these
        let postGamePanel = SKSpriteNode(color: .darkGray, size: CGSize(width: self.frame.width/2.0, height: self.frame.width/4.0))
        postGamePanel.zPosition = 60.0
        postGameContainerNode.addChild(postGamePanel)
        
        let postGamePanelTitle = SKLabelNode(fontNamed: "AmericanTypewriter")
        postGamePanelTitle.text = "Game Over: \(self.playerRed.lives > 0 ? "Red" : "Blue") Wins!" // this logic is filler, need two player scores
        postGamePanelTitle.zPosition = 80.0
        postGamePanelTitle.fontSize = 30
        postGamePanelTitle.fontColor = SKColor.white
    
        postGamePanelTitle.position = CGPoint(x: postGamePanel.frame.midX, y: postGamePanel.frame.maxY - 50.0)
        postGamePanel.addChild(postGamePanelTitle)
        

        let replayButton = SKSpriteNode(imageNamed: "resume")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(menuScale)
        replayButton.position = CGPoint(x: postGamePanel.frame.midX - replayButton.frame.width, y:postGamePanel.frame.midY - 20.0)
        postGamePanel.addChild(replayButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitButtonNodeName
        quitButton.setScale(menuScale)
        quitButton.position = CGPoint(x: postGamePanel.frame.midX + quitButton.frame.width , y: postGamePanel.frame.midY - 20.0)
        postGamePanel.addChild(quitButton)
    }
    
    func createExplosion(position: CGPoint, scale: CGFloat, timePerFrame: CGFloat) {
        let explosionNode = SKSpriteNode(imageNamed: "Explosion_1")
        explosionNode.name = "ExplosionNode"
        explosionNode.zPosition = 10.0
        explosionNode.setScale(scale)
        explosionNode.position = position
        
        addChild(explosionNode)
        var explosionTextures: [SKTexture] = []
        for i in 1...7 {
            explosionTextures.append(SKTexture(imageNamed: "Explosion_\(i)"))
        }
        explosionNode.run(.sequence([.animate(with: explosionTextures, timePerFrame: timePerFrame), .removeFromParent()]))
    }
    
    func resetOnHit(){
        playerRed.canFire = true
        playerBlue.canFire = true
        self.resetPositions()
    }
    
    func resetPositions(){
        if !isGameOver{
            
            for missile in missiles {
                missile.removeFromParent()
            }
            missiles.removeAll()

            playerRed.removeFromParent()
            playerBlue.removeFromParent()
            
            let startPositionOffset = 5.0 +  boundaryWidth
            playerRed.zRotation = 3.14
            playerRed.position = CGPoint(x: frame.width - (playerRed.frame.width/2.0) - startPositionOffset, y: self.frame.height - (playerRed.frame.height/2.0) - startPositionOffset)
            
            playerBlue.zRotation = 0.0
            playerBlue.position = CGPoint(x: playerBlue.frame.width/2.0 + startPositionOffset, y: self.bottomControlPanelHeight +  playerBlue.frame.height/2.0 + startPositionOffset)
            self.imminentReset = false
            
            addChild(playerRed)
            addChild(playerBlue)
        }
    }
    

   
 
   
}
    
//MARK: - SKPhysicsContactDelegate
extension TankGameScene: SKPhysicsContactDelegate {
    
    // Handle collisions for each player and bullets and respond appropriately... maybe bullets will just bounce appropriately if no gravity?
    func didBegin(_ contact: SKPhysicsContact) {
        let A = contact.bodyA.categoryBitMask
        let B = contact.bodyB.categoryBitMask
        
        // If A is missile and B is missile then both blowup
        if (A == TankGamePhysicsCategory.Missile && B == TankGamePhysicsCategory.Missile) {
            if let missileA = contact.bodyA.node, let missileB = contact.bodyB.node {
                self.createExplosion(position: missileA.position, scale: CGFloat(1.0), timePerFrame: 0.08)
                missileA.removeFromParent()
                missileB.removeFromParent()
                
            }
        }
    
        
        else if (B == TankGamePhysicsCategory.Missile && A == TankGamePhysicsCategory.Player) {
            if let player = contact.bodyA.node, let missile = contact.bodyB.node {
                self.createExplosion(position: missile.position, scale: CGFloat(2.5), timePerFrame: 0.13)
                missile.removeFromParent()
                player.removeFromParent()
                
                self.imminentReset = true
                        
                self.run(.sequence([
                    .wait(forDuration: 1.0),
                    .run{[weak self] in
                        print("reset")
                        self?.checkEndgameConditions()
                        self?.resetOnHit()
                }]))
                
                (player as! playerNode).decrementLives()
                
            }
        }
    
        
        // If B is missle and A is boundary, then decrease missile life by 1 or blowup if life == 0
    
        else if (B == TankGamePhysicsCategory.Missile && A == TankGamePhysicsCategory.Boundary) {
            if let missile = contact.bodyB.node{
                (missile as! missileNode).collide()
            }
        }
        
        
        
        
        
        
        
        
    }
    
}
