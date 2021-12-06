//
//  DrunkFightGameScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/15/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

// Powerup Enumerations
enum Powerups {
    case SingleFire, MultiFire, RapidFire, jSONFire
}
class playerNode : SKSpriteNode {
    
    var lives: Int!
    var fireMode: Powerups = Powerups.SingleFire
    var canFire: Bool!
    var cooldownLeft: CGFloat!
    var currentMaxCooldown: CGFloat!
    var defaultCooldown: CGFloat!
    var playerColor: String!
    var velocityMultiplier: CGFloat!
    var powerUpDuration: CGFloat = 0.0
    var originalPowerupDuration: CGFloat = 0.0
    var isMoving: Bool = false
    
    init(imageNamed: String, lives: Int, velocity: CGFloat, defaultCooldown: CGFloat, playerColor: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .black, size: texture.size())
        
        self.playerColor = playerColor
        self.lives = lives
        self.velocityMultiplier = velocity
        self.cooldownLeft = 0.0
        self.canFire = self.cooldownLeft == 0.0 ? true : false
        self.defaultCooldown = defaultCooldown
        self.currentMaxCooldown = self.defaultCooldown
        
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
        let js = AnalogJoystick(diameter: 75, colors: (substrate: .blue, stick: .blue), images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jSubstrate")))
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
    

    let darkBlueColor = UIColor(red: 3/255.0, green: 168/255.0, blue: 244/255.0, alpha: 1.0)
    let darkRedColor = UIColor(red: 202/255.0, green: 47/255.0, blue: 8/255.0, alpha: 1.0)
    
    // Temp vars... until I flesh more stuff out
    let missileRadius: CGFloat = 5
    let boundaryWidth: CGFloat = 5
    let wallWidth: CGFloat = 10
    
    let bottomControlPanelHeight: CGFloat = 50.0
    var bottomControlPanel: SKSpriteNode!
    
    // Each player is represented by a tank
    var playerRed: playerNode!
    var playerBlue: playerNode!
    
    let singleFireCooldownTime: CGFloat = 4.0
    
    var redScoreNode: SKLabelNode!
    var blueScoreNode: SKLabelNode!
    
//    var redCooldownNode : SKShapeNode!
//    var blueCooldownNode: SKShapeNode!
    var redCooldownNode : SKSpriteNode!
    var blueCooldownNode: SKSpriteNode!
    
    var redPowerupDurationNode: SKSpriteNode!
    var bluePowerupDurationNode: SKSpriteNode!
    
//    var powerupShadowNode: SKSpriteNode!
    var powerupShadowNode: SKShapeNode!
    
    let powerupCooldownNodeColor = UIColor.purple
    
    var redLaunchButton: SKSpriteNode!
    var blueLaunchButton: SKSpriteNode!
    
    var powerUp: SKSpriteNode! // TODO: Add multiple powerUp types

        
    var walls: [SKShapeNode] = []
    
    let boundaryColor = UIColor.white
    let wallColor = UIColor.white
    
    var redTextures: [SKTexture] = []
    var blueTextures: [SKTexture] = []
    
    var possiblePowerups: [SKSpriteNode] = []
    var possiblePowerupPositions: [CGPoint]!
    
    let powerupDefaultDespawnTime: CGFloat = 10.0
    
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
    
    let redPowerupDurationNodeName = "redPowerupDurationNode"
    let bluePowerupDurationNodeName = "bluePowerupDurationNode"
    
    let rapidFireNodeName = "rapidFireNode"
    let multiFireNodeName = "multiFireNode"
    let jSONFireNodeName = "jSONFireNode"
    let randomBombNodeName = "randomBombNode"
    
    let powerupRepeaterActionKey = "powerupRepeaterAction"
    
    let activePowerupActionKey = "activePowerupAction" // This is uses to remove the powerup on reset after hit
    
    var activePowerup: SKSpriteNode? = nil
    
    let rapidFireCooldownTime: CGFloat = 0.5
    let multiFireCooldownTime: CGFloat = 2.5
    let jSONFireCooldownTime: CGFloat = 3.0
    
    let rapidFirePowerupDuration = 5.0
    let multiFirePowerupDuration = 6.0
    let jSONFirePowerupDuration = 2.0
    
    let originalCooldownNodeWidth: CGFloat = 70.0
    let originalPowerupNodeWidth: CGFloat = 70.0
    
    let bombExplosionRadius: CGFloat = 70.0
    
    let jSONMissileDuration: CGFloat = 100000.0
    let jSONMaxCollisions: Int = 100
    let jSONVelocityMultiplier: CGFloat = 100.0
    let jSONRadius: CGFloat = SKSpriteNode(imageNamed: "JSON_Missile1").frame.width/2.0
    
    var bombInProgress = false

    var prevRedPos: CGPoint!
    var prevBluePos: CGPoint!
    
    //MARK: - Systems
    /*
     Entry point for game - start the game by spawning nodes
     */
    override func didMove(to view: SKView) {
        self.startGame()
        
    }
    

    /*
     Handle touch events from users
     */
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
                handleMissileLaunch(player: playerBlue)
            } else if node.name == redLaunchMissileButtonNodeName && !imminentReset && playerRed.canFire{
                handleMissileLaunch(player: playerRed)
            }
            
        }
    }
    
    /*
     Scale the cooldown node for each player to the appropriate size as time advances
     */
    func handleCooldown(player: playerNode, cooldownNode: SKSpriteNode){
        
        if player.cooldownLeft > 0.0{
            player.canFire = false
            updateCooldownNode(cooldownNode: cooldownNode, originalTime: player.currentMaxCooldown, timeLeft: player.cooldownLeft)
            player.cooldownLeft -= CGFloat(dt)
            
        } else {
            player.canFire = true
            player.cooldownLeft = 0.0
            cooldownNode.size = CGSize(width: originalCooldownNodeWidth, height: cooldownNode.frame.height)
        }
        
    }
    /*
     Scale the cooldown node for each player to the appropriate size as time advances
     */
    func updateCooldownNode(cooldownNode: SKSpriteNode ,originalTime: CGFloat, timeLeft: CGFloat){
        let percentTimeLeft = timeLeft/originalTime
        
        let newCooldownNodeWidth = originalCooldownNodeWidth * percentTimeLeft
        
        cooldownNode.size = CGSize(width: newCooldownNodeWidth, height: cooldownNode.frame.height)
        
    }
    /*
     Scale the power duration nodes the appropriate size as time advances
     */
    func handlePowerupDuration(player: playerNode, powerupNode: SKSpriteNode){
        player.powerUpDuration -= CGFloat(dt)
        if player.powerUpDuration <= 0.0{
            powerupNode.removeFromParent()
        } else {
            
            let percentTimeLeft = player.powerUpDuration / player.originalPowerupDuration
            let newWidth = originalPowerupNodeWidth * percentTimeLeft
            powerupNode.size = CGSize(width: newWidth, height: powerupNode.frame.height)
        }
    }
    
    /*
     Update loop for game - called automatically by SpriteKit
     */
    override func update(_ currentTime: TimeInterval) {
        // Update time tracking variables
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        // Animate players if they are moving
        if (playerRed.position.x == prevRedPos.x && playerRed.position.y == prevRedPos.y){
            playerRed.removeAction(forKey: "animation")
            playerRed.texture = SKTexture(imageNamed: "redTank1")
            playerRed.isMoving = false
        } else {
            
            if !playerRed.isMoving{
                playerRed.run(.repeatForever(.animate(with: redTextures, timePerFrame: 0.02)), withKey: "animation")
            }
        
            playerRed.isMoving = true
            prevRedPos = playerRed.position
        }
        
        if (playerBlue.position.x == prevBluePos.x && playerBlue.position.y == prevBluePos.y){
            playerBlue.removeAction(forKey: "animation")
            playerBlue.texture = SKTexture(imageNamed: "blueTank1")
            playerBlue.isMoving = false
        } else {
            
            if !playerBlue.isMoving{
                playerBlue.run(.repeatForever(.animate(with: blueTextures, timePerFrame: 0.02)), withKey: "animation")
            }
        
            playerBlue.isMoving = true
            prevBluePos = playerBlue.position
        }
        
        
        // Handle even when game is over
        if isGameOver {
            if !isPaused{
                createPostGamePanel()
                isPaused = true
            }
        // If game is not over, perform other operations
        } else {
            
            // Move powerups shadow to bounce with powerup
            if let activePowerup = activePowerup, let powerupShadowNode = powerupShadowNode {
                powerupShadowNode.position = CGPoint(x: activePowerup.position.x + 3.0, y: activePowerup.position.y - 5.0)
            }
            
            handleCooldown(player: playerRed, cooldownNode: redCooldownNode)
            handleCooldown(player: playerBlue, cooldownNode: blueCooldownNode)
            
            if playerRed.powerUpDuration > 0.0 {handlePowerupDuration(player: playerRed, powerupNode: redPowerupDurationNode)}
            if playerBlue.powerUpDuration > 0.0 {handlePowerupDuration(player: playerBlue, powerupNode: bluePowerupDurationNode)}
            
            // Update scoreboard
            redScoreNode.text = "\(playerRed.lives!)"
            blueScoreNode.text = "\(playerBlue.lives!)"
            
            // Keep missiles rotated to correct degree to match direction vector
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
    
    // Launch missile for given player
    func handleMissileLaunch(player: playerNode){
        
        switch player.fireMode {
            
        case Powerups.MultiFire:
            let rad = player.zRotation + Double.pi/2
            createMissile(positionAt: CGPoint(x:  player.position.x + ((missileRadius * 7.5) * cos(rad)), y: player.position.y + ((missileRadius*7.5) * sin(rad)))
                            ,withVelocity: CGVector(dx: cos(rad) * 200, dy:sin(rad)*200))
            let radOffset = 0.275
            createMissile(positionAt: CGPoint(x:  player.position.x + ((missileRadius * 7.5) * cos(rad + radOffset)), y: player.position.y + ((missileRadius*7.5) * sin(rad + radOffset)))
                            ,withVelocity: CGVector(dx: cos(rad + radOffset) * 200, dy:sin(rad + radOffset)*200))
            createMissile(positionAt: CGPoint(x:  player.position.x + ((missileRadius * 7.5) * cos(rad - radOffset)), y: player.position.y + ((missileRadius*7.5) * sin(rad - radOffset)))
                            ,withVelocity: CGVector(dx: cos(rad - radOffset) * 200, dy:sin(rad - radOffset)*200))
        
        case Powerups.jSONFire:
            let rad = player.zRotation + Double.pi/2
            createJSON(positionAt: CGPoint(x:  player.position.x + ((jSONRadius + player.frame.height/2.0) * cos(rad)), y: player.position.y + ((jSONRadius + player.frame.height/2.0) * sin(rad)))
                            ,withVelocity: CGVector(dx: cos(rad) * jSONVelocityMultiplier, dy:sin(rad)*jSONVelocityMultiplier))
            
        // Single Fire and Rapid Fire don't require any modification
        default:
            let rad = player.zRotation + Double.pi/2
            createMissile(positionAt: CGPoint(x:  player.position.x + ((missileRadius * 7.5) * cos(rad)), y: player.position.y + ((missileRadius*7.5) * sin(rad)))
                            ,withVelocity: CGVector(dx: cos(rad) * 200, dy:sin(rad)*200))
            
        }
        
        player.cooldownLeft = player.currentMaxCooldown
    }
    /*
     Call various functions to create appropriate nodes and generally setup the game
     */
    func startGame(){
        self.removeAllChildren()
        setupPhysicsWorld()
        createBottomControlPanel()
        createPauseButton()
        createPlayers()
        createBackground()
        createBoundaries()
        createWalls()
        setupPowerups()
    }
    
    /*
     If either player has 0 lives, then the game is over
     */
    func checkEndgameConditions(){
        if playerRed.lives! < 1 || playerBlue.lives! < 1{
            isGameOver = true
        }
    }
    
    /*
     Setup joysticks for each player and setup handlers
     */
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


    /*
     Setup phyics on scene to have no gravity
     */
    func setupPhysicsWorld(){
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // No gravity in this world
        self.physicsWorld.contactDelegate = self
    }
    
    /*
     Create outside boundaries of the game
     */
    func createBoundaries() {
        
        func createVeritcalBoundary(x: CGFloat){
            let boundarySize = CGSize(width: boundaryWidth, height: self.size.height)
            let boundary = SKShapeNode(rectOf: boundarySize)
            boundary.physicsBody = SKPhysicsBody(rectangleOf: boundarySize).ideal().manualMovement()
            boundary.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Boundary

            boundary.position = CGPoint(x: x, y: self.size.height/2.0)
            boundary.strokeColor = boundaryColor
            boundary.fillColor = boundaryColor
            boundary.zPosition = 100.0

            self.addChild(boundary)
            
            let shadow = SKSpriteNode(color: .lightGray, size: boundarySize)
            shadow.blendMode = SKBlendMode.alpha
            shadow.colorBlendFactor = 1
            shadow.color = SKColor.black
            shadow.zPosition = 1.0
            shadow.alpha = 0.3
            shadow.position = CGPoint(x: boundary.position.x + 2.5, y: boundary.position.y)
            self.addChild(shadow)
            
            let shadow2 = SKSpriteNode(color: .lightGray, size: boundarySize)
            shadow2.blendMode = SKBlendMode.alpha
            shadow2.colorBlendFactor = 1
            shadow2.color = SKColor.black
            shadow2.zPosition = 1.0
            shadow2.alpha = 0.3
            shadow2.position = CGPoint(x: boundary.position.x + 5.0, y: boundary.position.y)
            self.addChild(shadow2)
            
        }
        func createHorizontalBoundary(y: CGFloat){
            let boundarySize = CGSize(width: self.size.width, height: boundaryWidth)
            let boundary = SKShapeNode(rectOf: boundarySize)
            boundary.physicsBody = SKPhysicsBody(rectangleOf: boundarySize).ideal().manualMovement()
            boundary.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Boundary

            
            boundary.position = CGPoint(x: self.frame.width/2.0, y: y)
            boundary.strokeColor = boundaryColor
            boundary.fillColor = boundaryColor
            boundary.zPosition = 3.0
            self.addChild(boundary)
            
            let shadow = SKSpriteNode(color: .lightGray, size: boundarySize)
            shadow.blendMode = SKBlendMode.alpha
            shadow.colorBlendFactor = 1
            shadow.color = SKColor.black
            shadow.zPosition = 1.0
            shadow.alpha = 0.3
            shadow.position = CGPoint(x: boundary.position.x, y: boundary.position.y - 2.5)
            self.addChild(shadow)
            
            let shadow2 = SKSpriteNode(color: .lightGray, size: boundarySize)
            shadow2.blendMode = SKBlendMode.alpha
            shadow2.colorBlendFactor = 1
            shadow2.color = SKColor.black
            shadow2.zPosition = 1.0
            shadow2.alpha = 0.3
            shadow2.position = CGPoint(x: boundary.position.x, y: boundary.position.y - 5.0)
            self.addChild(shadow2)
        }
        
        createVeritcalBoundary(x: boundaryWidth/2.0)
        createVeritcalBoundary(x: self.size.width - boundaryWidth/2.0)
        
        createHorizontalBoundary(y: self.bottomControlPanel.frame.height + boundaryWidth/2.0)
        createHorizontalBoundary(y: self.frame.height - boundaryWidth/2.0)
        
    }
    
    /*
     Generate interior walls for game
     */
    func createWalls(){
        
        func createWall(position: CGPoint, size: CGSize){
            let wall = SKShapeNode(rectOf: size)
            wall.physicsBody = SKPhysicsBody(rectangleOf: size).ideal().manualMovement()
            
            wall.position = position
            wall.strokeColor = wallColor
            wall.fillColor = wallColor
            wall.zPosition = 2.0
            wall.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Boundary
            
            let shadow = SKSpriteNode(color: .lightGray, size: size)
            shadow.blendMode = SKBlendMode.alpha
            shadow.colorBlendFactor = 1
            shadow.color = SKColor.black
            shadow.zPosition = 1.0
            shadow.alpha = 0.25
            shadow.position = CGPoint(x: position.x + 3.5, y: position.y - 3.5)
            
            let shadow2 = SKSpriteNode(color: .lightGray, size: size)
            shadow2.blendMode = SKBlendMode.alpha
            shadow2.colorBlendFactor = 1
            shadow2.color = SKColor.black
            shadow2.zPosition = 1.0
            shadow2.alpha = 0.25
            shadow2.position = CGPoint(x: position.x + 7.0, y: position.y - 7.0)
            
            self.addChild(shadow)
            self.addChild(shadow2)

            self.addChild(wall)
        }
        createWall(position: CGPoint(x: self.size.width/4.0, y: (self.size.height/3.0) * 2), size: CGSize(width: 10.0, height: 70))
        createWall(position: CGPoint(x: self.size.width/4.0 + 20, y: (self.size.height/3.0) * 2 + 40), size: CGSize(width: 50.0, height: 10))
        
        createWall(position: CGPoint(x: (self.size.width/4.0) * 3, y: self.size.height/2.0), size: CGSize(width: 10.0, height: 70))
        createWall(position: CGPoint(x: (self.size.width/4.0) * 3 - 20, y: (self.size.height/2.0) - 40), size: CGSize(width: 50.0, height: 10))
        
        createWall(position: CGPoint(x: frame.midX + 30.0, y: bottomControlPanelHeight + boundaryWidth + 30.0),
                   size: CGSize(width: 10.0, height: 80.0))
        
        createWall(position: CGPoint(x: frame.midX - 30.0, y: frame.height - boundaryWidth - 30.0),
                   size: CGSize(width: 10.0, height: 80.0))
        
        createWall(position: CGPoint(x: frame.width - 30.0 - boundaryWidth, y: frame.midY + 30.0),
                   size: CGSize(width: 80.0, height: 10.0))
        
        createWall(position: CGPoint(x: 0 + 30.0 + boundaryWidth, y: frame.midY - 30.0),
                   size: CGSize(width: 80.0, height: 10.0))

    }
    
    /*
     Create the background node for the game
     */
    func createBackground(){
        let background = SKSpriteNode(imageNamed: "tankGameBackground")
        background.name = "Background"
        background.anchorPoint = .zero
        background.position = CGPoint(x: 0.0, y: 0.0)
        background.zPosition = -1.0 // Make sure is appears behind other children
        self.addChild(background)
    }
    
    /*
     Create red and blue players
     */
    func createPlayers(){
        
        let playerScaleFactor = 0.5
        
        // Red Player
        
        // Create and position
        playerRed = playerNode(imageNamed: "redTank1", lives: playerStartLives, velocity: startPlayerVelocityMultiplier, defaultCooldown: singleFireCooldownTime, playerColor: "red")
        playerRed.name = "PlayerRed"
        playerRed.zPosition = 5.0
        playerRed.setScale(playerScaleFactor)
        playerRed.position = CGPoint(x: frame.width - (playerRed.frame.width/2.0) - 20.0, y: self.frame.height/2.0 - (playerRed.frame.height/2.0))
        
        // Set to face downwards originally
        playerRed.zRotation = 3.14/2.0
        
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
        playerBlue = playerNode(imageNamed: "blueTank1", lives: playerStartLives, velocity: startPlayerVelocityMultiplier, defaultCooldown: singleFireCooldownTime, playerColor: "blue")
        playerBlue.name = "PlayerBlue"
        playerBlue.zPosition = 5.0
        playerBlue.zRotation = -(3.14/2.0)
        playerBlue.setScale(playerScaleFactor)
        playerBlue.position = CGPoint(x: 0.0 + (playerBlue.frame.width/2.0) + 20.0, y: self.frame.height/2.0 + (playerRed.frame.height))
        
        // Add physics body
        let blueScaledSize = CGSize(width: playerBlue.texture!.size().width * playerScaleFactor, height: playerBlue.texture!.size().height * playerScaleFactor)
        playerBlue.physicsBody = SKPhysicsBody(texture: playerBlue.texture!, size: blueScaledSize)
        playerBlue.physicsBody!.affectedByGravity = false
        playerBlue.physicsBody!.restitution = 0.0
        playerBlue.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Player
        playerBlue.physicsBody!.contactTestBitMask = TankGamePhysicsCategory.Missile | TankGamePhysicsCategory.Powerup
        self.addChild(playerBlue)
        
        
        // Populate animation arrays
        for i in 1...12 {
            redTextures.append(SKTexture(imageNamed: "redTank\(i)"))
        }
        
        for i in 1...12 {
            blueTextures.append(SKTexture(imageNamed: "blueTank\(i)"))
        }
        
        // Create variable for help in properly animating players
        prevRedPos = playerRed.position
        prevBluePos = playerBlue.position
        
    }
    
    /*
     Create panel at bottom of screen to house scoreboard and controls
     */
    func createBottomControlPanel(){
        let offWhite = CGFloat(255.0/255.0)
        bottomControlPanel = SKSpriteNode(color: .white, size: CGSize(width: self.frame.width, height: bottomControlPanelHeight))
        bottomControlPanel.name = "bottomControlPanel"
        bottomControlPanel.anchorPoint = .zero
        bottomControlPanel.color = UIColor(red: offWhite, green: offWhite, blue: offWhite, alpha: 1.0)
        bottomControlPanel.zPosition = 2.0
        bottomControlPanel.position = CGPoint(x: 0.0, y:0.0)
    
        self.addChild(bottomControlPanel)
        
        setupJoysticks()
        setupLaunchButtonsAndCooldown()
        createScoreboard()
    }
    
    /*
     Setup player controls and cooldown nodes
     */
    func setupLaunchButtonsAndCooldown() {
        let offsetFromJoystick = 10.0
        let verticalOffset = 1.0
        let buttonScale = 0.5
        let buttonAlpha = 1.0
        
        redLaunchButton = SKSpriteNode(imageNamed: "redButton")
        redLaunchButton.name = redLaunchMissileButtonNodeName
        redLaunchButton.zPosition = 81.0
        redLaunchButton.alpha = buttonAlpha
        redLaunchButton.setScale(buttonScale)
        redLaunchButton.position = CGPoint(x: analogJoystickRed.position.x - redLaunchButton.frame.width  - offsetFromJoystick ,y: analogJoystickRed.position.y)
        
        addChild(redLaunchButton)
        
        blueLaunchButton = SKSpriteNode(imageNamed: "blueButton")
        blueLaunchButton.name = blueLaunchMissileButtonNodeName
        blueLaunchButton.zPosition = 81.0
        blueLaunchButton.alpha = buttonAlpha
        blueLaunchButton.setScale(buttonScale)
        blueLaunchButton.position = CGPoint(x: analogJoystickBlue.position.x + blueLaunchButton.frame.width + offsetFromJoystick ,y: analogJoystickBlue.position.y)
        
        addChild(blueLaunchButton)
        
        redCooldownNode = SKSpriteNode(color: darkRedColor, size: CGSize(width: originalCooldownNodeWidth, height: 10.0))
        redCooldownNode.name = redCooldownNodeName
        redCooldownNode.zPosition = 81.0
        redCooldownNode.position = CGPoint(x: redLaunchButton.position.x,
                                           y: redLaunchButton.position.y - redLaunchButton.frame.height/2.0 - redCooldownNode.frame.height/2.0 - verticalOffset)

        addChild(redCooldownNode)

        blueCooldownNode = SKSpriteNode(color: darkBlueColor, size: CGSize(width: originalCooldownNodeWidth, height: 10.0))
        blueCooldownNode.name = blueCooldownNodeName
        blueCooldownNode.zPosition = 81.0
        blueCooldownNode.position = CGPoint(x: blueLaunchButton.position.x,
                                            y: blueLaunchButton.position.y - blueLaunchButton.frame.height/2.0 - blueCooldownNode.frame.height/2.0 - verticalOffset)

        addChild(blueCooldownNode)

        
        redPowerupDurationNode = SKSpriteNode(color: powerupCooldownNodeColor, size: CGSize(width: originalCooldownNodeWidth, height: 10.0))
        redPowerupDurationNode.name = redPowerupDurationNodeName
        redPowerupDurationNode.zPosition = 81.0
        redPowerupDurationNode.position = CGPoint(x: redCooldownNode.position.x,
                                                  y:redCooldownNode.position.y - redCooldownNode.frame.height/2.0 - redPowerupDurationNode.frame.height/2.0 - verticalOffset)
        
        bluePowerupDurationNode = SKSpriteNode(color: powerupCooldownNodeColor, size: CGSize(width: originalCooldownNodeWidth, height: 10.0))
        bluePowerupDurationNode.name = bluePowerupDurationNodeName
        bluePowerupDurationNode.zPosition = 81.0
        bluePowerupDurationNode.position = CGPoint(x: blueCooldownNode.position.x,
                                                  y:blueCooldownNode.position.y - blueCooldownNode.frame.height/2.0 - bluePowerupDurationNode.frame.height/2.0 - verticalOffset)
        
        
    }
    
    /*
     Configure powerups and populate spawning array
     */
    
    func setupPowerups(){
        let scaleFactor = 0.7
        // Specify possible powerups positions
        possiblePowerupPositions = [CGPoint(x: frame.midX, y: frame.midY),
                                    CGPoint(x: frame.midX, y: frame.midY + 100 + bottomControlPanelHeight/2.0),
                                    CGPoint(x: frame.midX, y: frame.midY - 100),
                                    CGPoint(x: frame.midX - 100.0, y: frame.midY),
                                    CGPoint(x: frame.midX + 100.0, y: frame.midY)]
        
        
        // Rapid Fire Powerup Node
        let rapidFireNode = SKSpriteNode(imageNamed: "rapidFirePowerup")
        rapidFireNode.name = rapidFireNodeName
        rapidFireNode.zPosition = 5.0
        rapidFireNode.setScale(scaleFactor)
        rapidFireNode.physicsBody = SKPhysicsBody(circleOfRadius: rapidFireNode.frame.width/2.0).ideal().manualMovement()
        rapidFireNode.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Powerup

        // Multi Fire Powerup Node
        let multiFireNode = SKSpriteNode(imageNamed: "multiFirePowerup")
        multiFireNode.name = multiFireNodeName
        multiFireNode.zPosition = 5.0
        multiFireNode.setScale(scaleFactor)
        multiFireNode.physicsBody = SKPhysicsBody(circleOfRadius: multiFireNode.frame.width/2.0).ideal().manualMovement()
        multiFireNode.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Powerup

        // JSON Fire Node
        let jSONFireNode = SKSpriteNode(imageNamed: "jSONFirePowerup")
        jSONFireNode.name = jSONFireNodeName
        jSONFireNode.setScale(scaleFactor)
        jSONFireNode.zPosition = 5.0
        jSONFireNode.physicsBody = SKPhysicsBody(circleOfRadius: jSONFireNode.frame.width/2.0).ideal().manualMovement()
        jSONFireNode.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Powerup
        
        // Random Bomb Spawn
        let randomBombNode = SKSpriteNode(imageNamed: "bombPowerup")
        randomBombNode.name = randomBombNodeName
        randomBombNode.zPosition = 5.0
        randomBombNode.setScale(scaleFactor)
        
        let randomBombNodeScaledSize = CGSize(width: randomBombNode.texture!.size().width * scaleFactor,
                                          height: randomBombNode.texture!.size().height * scaleFactor)
        randomBombNode.physicsBody = SKPhysicsBody(texture: randomBombNode.texture!, size: randomBombNodeScaledSize).ideal().manualMovement()

        randomBombNode.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Powerup
        
        possiblePowerups.append(rapidFireNode)
        possiblePowerups.append(multiFireNode)
        possiblePowerups.append(jSONFireNode)
        possiblePowerups.append(randomBombNode)
        
        // Setup loop to infinitely spawn powerups
        let powerupRepeaterAction = SKAction.repeatForever(.sequence([
            .wait(forDuration: powerupDefaultDespawnTime),
            .run {
                self.spawnRandomPowerup()
            }
        ]))
        self.run(powerupRepeaterAction, withKey: powerupRepeaterActionKey)
        
    }
    
    /*
     Function to pick random powerup and spawn in one of a few specified locations around the map
     */
    func spawnRandomPowerup(){
        let timeBetweenMovement = 0.2
        if let powerup = activePowerup{
            powerup.removeFromParent()
            powerup.removeAllActions()
            powerupShadowNode.removeFromParent()
            activePowerup = nil
        }
        
        // Pick random powerup from array and random spawn from array and add to scene
        if let spawn = self.possiblePowerupPositions.randomElement(), let powerup = self.possiblePowerups.randomElement(){
            powerup.position = spawn
            activePowerup = powerup
            // Have powerups bounce infinitely
            powerup.run(.repeatForever(.sequence([
                .wait(forDuration: timeBetweenMovement),
                .run {powerup.position.y += 1.0},
                .wait(forDuration: timeBetweenMovement),
                .run {powerup.position.y += 1.0},
                .wait(forDuration: timeBetweenMovement),
                .run {powerup.position.y += 1.0},
                .wait(forDuration: timeBetweenMovement),
                .run {powerup.position.y -= 1.0},
                .wait(forDuration: timeBetweenMovement),
                .run {powerup.position.y -= 1.0},
                .wait(forDuration: timeBetweenMovement),
                .run {powerup.position.y -= 1.0},
            ])))
            
            self.addChild(powerup)
            
            // Create shadow node for powerup
            powerupShadowNode = SKShapeNode(circleOfRadius: powerup.frame.width/2.0)
            powerupShadowNode.fillColor = .black
            powerupShadowNode.strokeColor = .black
            powerupShadowNode.alpha = 0.25
            powerupShadowNode.zPosition = 1.0
            powerupShadowNode.position = CGPoint(x: powerup.position.x + 3.0, y: powerup.position.y - 5.0)
            
            self.addChild(powerupShadowNode)
             
        } else {
            print("Emty Powerup or Position Array")
        }
        
    }
    
    /*
     Create an infinite JSON missile
     */
    func createJSON(positionAt position: CGPoint, withVelocity velocity: CGVector){
        //TODO: Comeback and handle velocity
        let json = missileNode(imageNamed: "JSON_Missile1", maxCollisions: self.jSONMaxCollisions, velocity: 0.0)

        json.position = position
        json.setScale(0.5)
        json.name = "JSON"
        json.physicsBody = SKPhysicsBody(circleOfRadius: json.frame.width/2.0).ideal()
        json.physicsBody!.velocity = velocity
        json.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Missile
        json.physicsBody!.contactTestBitMask = TankGamePhysicsCategory.Missile | TankGamePhysicsCategory.Player | TankGamePhysicsCategory.Boundary

        
        self.addChild(json)
        self.missiles.append(json)
                
        var jsonTextures: [SKTexture] = []
        for i in 1...3 {
            jsonTextures.append(SKTexture(imageNamed: "JSON_Missile\(i)"))
        }
        json.run(.repeatForever(.animate(with: jsonTextures, timePerFrame: 0.08)))
    }
    
    /*
     Create missile
     */
    func createMissile(positionAt position: CGPoint, withVelocity velocity: CGVector){
        
        let missile = missileNode(imageNamed: "missile1", maxCollisions: self.missileStandardMaxCollisions, velocity: 0.0)
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

        missile.run(.repeatForever(.animate(with: missileTextures, timePerFrame: 0.08)))
        
    }
    
    /*
     Create scoreboard node in bottom panel
     */
    func createScoreboard(){
        let middleOffset = 30.0
        redScoreNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        redScoreNode.text = "\(playerStartLives)"
        redScoreNode.fontSize = 30.0
        redScoreNode.fontColor =  darkRedColor
        redScoreNode.zPosition = 5.0
        redScoreNode.position = CGPoint(x: bottomControlPanel.frame.width/2.0 + redScoreNode.frame.width + middleOffset, y: bottomControlPanel.frame.height/2.0 - 10.0)
        
        self.addChild(redScoreNode)
        
        blueScoreNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        blueScoreNode.text = "\(playerStartLives)"
        blueScoreNode.fontSize = 30.0
        blueScoreNode.fontColor = darkBlueColor
        blueScoreNode.zPosition = 5.0
        blueScoreNode.position = CGPoint(x: bottomControlPanel.frame.width/2.0 - blueScoreNode.frame.width - middleOffset, y: bottomControlPanel.frame.height/2.0 - 10.0)
        
        self.addChild(blueScoreNode)
        
        let dashNode = SKLabelNode(fontNamed: "AmericanTypewriter")
        dashNode.text = "-"
        dashNode.fontSize = 40.0
        dashNode.horizontalAlignmentMode = .center
        dashNode.verticalAlignmentMode = .top
        dashNode.zPosition = 5.0
        dashNode.fontColor = .black
        dashNode.position = CGPoint(x: bottomControlPanel.frame.width/2.0 , y: bottomControlPanel.frame.height/2.0)
        
        self.addChild(dashNode)
  
    }
    
    /*
     Create pause button
     */
    func createPauseButton(){
        pauseButtonNode = SKSpriteNode(imageNamed: "pause")
        pauseButtonNode.setScale(0.08)
        pauseButtonNode.zPosition = 50.0
        pauseButtonNode.name = pauseButtonNodeName
        pauseButtonNode.position = CGPoint(x: 0.0 + pauseButtonNode.frame.width/2 + 10.0, y: self.frame.maxY - pauseButtonNode.frame.height/2 - 10.0)
        self.addChild(pauseButtonNode)
    }
    
    /*
     Create pause panel when pause button pushed
     */
    func createPausePanel(){
        let menuScale = 0.08
        
        pauseContainerNode.position  = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2.0 + bottomControlPanelHeight/2.0)
        self.addChild(pauseContainerNode)
        
        // Image will need to change for all of these
        let pauseGamePanel = SKSpriteNode(color: .darkGray, size: CGSize(width: self.frame.width/2.0, height: self.frame.width/4.0))
        pauseGamePanel.zPosition = 60.0
        pauseContainerNode.addChild(pauseGamePanel)
        
        let pauseGamePanelTitle = SKLabelNode(fontNamed: "")
        pauseGamePanelTitle.text = "Game Paused"
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
    
    /*
     Create post game menu when game is over
     */
    func createPostGamePanel(){
        let menuScale = 0.2
        
        postGameContainerNode.position  = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2.0 + bottomControlPanelHeight/2.0)
        self.addChild(postGameContainerNode)
        
        // Image will need to change for all of these
        let postGamePanel = SKSpriteNode(color: .darkGray, size: CGSize(width: self.frame.width/2.0, height: self.frame.width/4.0))
        postGamePanel.zPosition = 60.0
        postGameContainerNode.addChild(postGamePanel)
        
        var result = ""
        if (self.playerRed.lives == self.playerBlue.lives){
            result = "Everyone Loses!"
        } else if (self.playerRed.lives > self.playerBlue.lives){
            result = "Red Wins!"
        } else {
            result = "Blue Wins!"
        }
        
        
        let postGamePanelTitle = SKLabelNode(fontNamed: "AmericanTypewriter")
        postGamePanelTitle.text = "Game Over: \(result)"
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
    
    /*
     Create explosion with given conditions
     */
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
    
    /*
     Reset some game state on a player hit
     */
    func resetOnHit(){
        playerRed.canFire = true
        playerBlue.canFire = true
        playerRed.cooldownLeft = 0.0
        playerBlue.cooldownLeft = 0.0
        
        self.removeAction(forKey: "activePowerupActionKey_\(playerBlue.playerColor!)")
        self.removeAction(forKey: "activePowerupActionKey_\(playerRed.playerColor!)")

        self.resetPositions()
        
        // Remove powerup spawning action
        self.removeAction(forKey: powerupRepeaterActionKey)
        setupPowerups()
        
        // Active powerup may be nil
        if let powerup = self.activePowerup {
            powerup.removeFromParent()
            powerupShadowNode.removeFromParent()
            self.activePowerup = nil
        }
        
        if redPowerupDurationNode.inParentHierarchy(self){redPowerupDurationNode.removeFromParent()}
        if bluePowerupDurationNode.inParentHierarchy(self){bluePowerupDurationNode.removeFromParent()}

        
        playerBlue.fireMode = Powerups.SingleFire
        playerRed.fireMode = Powerups.SingleFire
    }
    
    /*
     Reset player to start positions
     */
    func resetPositions(){
    
        if !isGameOver{
            
            for missile in missiles {
                missile.removeFromParent()
            }
            missiles.removeAll()

            playerRed.removeFromParent()
            playerBlue.removeFromParent()
            
            playerRed.zRotation = 3.14/2.0
            playerRed.position = CGPoint(x: frame.width - (playerRed.frame.width/2.0) - 20.0, y: self.frame.height/2.0 - (playerRed.frame.height/2.0))

            
            playerBlue.zRotation = (-3.14/2.0)
            playerBlue.position = CGPoint(x: 0.0 + (playerBlue.frame.width/2.0) + 20.0, y: self.frame.height/2.0 + (playerRed.frame.height))
            self.imminentReset = false
            
            addChild(playerRed)
            addChild(playerBlue)
        }
    }
    
    /*
     Add a powerup duration for a player to track
     how much longer a powerup is active for
     */
    func addPowerupDurationNodeForPlayer(player: playerNode){
        if player.playerColor == playerRed.playerColor{
            // If node is already a child of self
            if redPowerupDurationNode.inParentHierarchy(self){
                redPowerupDurationNode.removeFromParent()
            }
            addChild(redPowerupDurationNode)
            
        } else if player.playerColor == playerBlue.playerColor {
            if bluePowerupDurationNode.inParentHierarchy(self){
                bluePowerupDurationNode.removeFromParent()
            }
            addChild(bluePowerupDurationNode)
        }
    }
    
    /*
     Explode a bomb that spawns from the bomb powerup
     */
    func explodeBombNode(bombNode: SKSpriteNode){
        bombNode.removeAllActions()

        if bombNode.inParentHierarchy(self){
            createExplosion(position: bombNode.position, scale: 3.5, timePerFrame: 0.1)
            bombNode.removeFromParent()
            
            var playerHit = false
            if playerRed.inParentHierarchy(self){
                
                if sqrt(pow(playerRed.position.x - bombNode.position.x, 2) + pow(playerRed.position.y - bombNode.position.y, 2)) < bombExplosionRadius {
                    playerHit = true
                    imminentReset = true
                    playerRed.removeFromParent()
                    playerRed.decrementLives()
                }
            }
            if playerBlue.inParentHierarchy(self){
                if sqrt(pow(playerBlue.position.x - bombNode.position.x, 2) + pow(playerBlue.position.y - bombNode.position.y, 2)) < bombExplosionRadius {
                    playerHit = true
                    imminentReset = true
                    playerBlue.removeFromParent()
                    playerBlue.decrementLives()
                }
            }
            if playerHit{
                self.run(.sequence([
                    .wait(forDuration: 1.0),
                    .run{[weak self] in
                        self?.checkEndgameConditions()
                        self?.resetOnHit()
                        
                }]))
            }
            bombInProgress = false
        }
    }
    
    func spawnBombNode(player: playerNode){
        
        // Make sure bomb spawns close to enemy and in bounds
        let minOffset  = 40.0
        let maxOffset = 70.0
        let minWallOffset = 5.0

        var xPos = player.playerColor == "red" ? playerBlue.position.x : playerRed.position.x
        var yPos = player.playerColor == "red" ? playerBlue.position.y : playerRed.position.y

        let xo = CGFloat(Double.random(in: minOffset...maxOffset))
        let yo = CGFloat(Double.random(in: minOffset...maxOffset))

        let xDirection = CGFloat(Double.random(in: -1...1) <= 0 ? -1 : 1)
        let yDirection = CGFloat(Double.random(in: -1...1) <= 0 ? -1 : 1)

        if (xPos + (xo * xDirection) >= (frame.width - boundaryWidth - minWallOffset)){
            xPos = frame.width - boundaryWidth - (minWallOffset * 2.0)
        }
        else if (xPos + (xo * xDirection) <= (0.0 + boundaryWidth + minWallOffset)){
            xPos = 0.0 + boundaryWidth + (minWallOffset * 2.0)
        } else {
            xPos = xPos + (xo * xDirection)
        }

        if (yPos + (yo * yDirection) >= (frame.height - boundaryWidth - minWallOffset)){
            yPos = frame.height - boundaryWidth - (minWallOffset * 2.0)
        } else if (yPos + (yo * yDirection) <= (0.0 + boundaryWidth + minWallOffset + bottomControlPanelHeight)){
            yPos = 0.0 + boundaryWidth + (minWallOffset * 2.0)
        } else {
            yPos = yPos + (yo * yDirection)
        }
                   
        let bombDuration = 1.0
        let bombScale = 1.5
        let numAnimationImages: Int = 6
        let bombNode = SKSpriteNode(imageNamed: "bomb0")
        bombNode.name = "bombNode"
        bombNode.setScale(bombScale)
        bombNode.zPosition = 5.0
        
        let bombScaledSize = CGSize(width: bombNode.texture!.size().width * bombScale, height: bombNode.texture!.size().height * bombScale)
        bombNode.physicsBody = SKPhysicsBody(texture: bombNode.texture!, size: bombScaledSize)
        
        bombNode.physicsBody!.categoryBitMask = TankGamePhysicsCategory.Bomb
        bombNode.physicsBody!.contactTestBitMask = TankGamePhysicsCategory.Missile | TankGamePhysicsCategory.Player
        
        bombNode.position = CGPoint(x: CGFloat(xPos), y: CGFloat(yPos))
        
        addChild(bombNode)
        
        var bombTextures: [SKTexture] = []
        
        for i in 1...numAnimationImages {
            bombTextures.append(SKTexture(imageNamed: "bomb\(i)"))
        }
        bombNode.run(.repeatForever(.animate(with: bombTextures, timePerFrame: CGFloat(bombDuration / CGFloat(numAnimationImages)))))
        
        bombNode.run(.scale(by: 1.2, duration: bombDuration))
        
        bombNode.run(.sequence([
            .wait(forDuration: bombDuration),
            .run{self.explodeBombNode(bombNode: bombNode)}
        ]))
    }
}
    
//MARK: - SKPhysicsContactDelegate
extension TankGameScene: SKPhysicsContactDelegate {
    
    /*
     Helper function for when a player and a powerup come into contact
     */
    func handlePoweupPlayerContact(player: playerNode, powerup: SKSpriteNode) {
        
        switch powerup.name {
            
        case rapidFireNodeName:
            player.fireMode = Powerups.RapidFire
            let rapidFireAction = SKAction.sequence([
                .run
                {
                    self.addPowerupDurationNodeForPlayer(player: player)
                    player.currentMaxCooldown = self.rapidFireCooldownTime
                    player.powerUpDuration = self.rapidFirePowerupDuration
                    player.originalPowerupDuration = self.rapidFirePowerupDuration
                },
                .wait(forDuration: rapidFirePowerupDuration),
                .run
                {
                    player.fireMode = Powerups.SingleFire
                    player.currentMaxCooldown = self.singleFireCooldownTime
                    player.powerUpDuration = 0.0
                    player.originalPowerupDuration = 0.0
                }
            ])
            print("activePowerupActionKey_\(player.playerColor!)")
            self.run(rapidFireAction, withKey: "activePowerupActionKey_\(player.playerColor!)")
            
            
        case multiFireNodeName:
            player.fireMode = Powerups.MultiFire
            let multiFireAction = SKAction.sequence([
                .run
                {
                    self.addPowerupDurationNodeForPlayer(player: player)
                    player.currentMaxCooldown = self.multiFireCooldownTime
                    player.powerUpDuration = self.multiFirePowerupDuration
                    player.originalPowerupDuration = self.multiFirePowerupDuration
                },
                .wait(forDuration: multiFirePowerupDuration),
                .run
                {
                    player.fireMode = Powerups.SingleFire
                    player.currentMaxCooldown = self.singleFireCooldownTime
                    player.powerUpDuration = 0.0
                    player.originalPowerupDuration = 0.0
                }
            ])
            self.run(multiFireAction, withKey: "activePowerupActionKey_\(player.playerColor!)")
        
        case randomBombNodeName:
            if !bombInProgress{
                spawnBombNode(player: player)
                bombInProgress = true
            }
        
        case jSONFireNodeName:
            player.fireMode = Powerups.jSONFire
            let jSONFireAction = SKAction.sequence([
                .run
                {
                    self.addPowerupDurationNodeForPlayer(player: player)
                    player.currentMaxCooldown = self.jSONFireCooldownTime
                    player.powerUpDuration = self.jSONFirePowerupDuration
                    player.originalPowerupDuration = self.jSONFirePowerupDuration
                    
                },
                .wait(forDuration: jSONFirePowerupDuration),
                .run
                {
                    player.fireMode = Powerups.SingleFire
                    player.currentMaxCooldown = self.singleFireCooldownTime
                    player.powerUpDuration = 0.0
                    player.originalPowerupDuration = 0.0
                }
            ])
            self.run(jSONFireAction, withKey: "activePowerupActionKey_\(player.playerColor!)")
        
        default:
            player.fireMode = Powerups.SingleFire
            print("This will never happen... right?")
        }
        
        powerup.removeFromParent()
        powerupShadowNode.removeFromParent()
        self.activePowerup = nil
    }
    
    // Handle collisions for each player and bullets and respond appropriately... maybe bullets will just bounce appropriately if no gravity?
    func didBegin(_ contact: SKPhysicsContact) {
        let A = contact.bodyA.categoryBitMask
        let B = contact.bodyB.categoryBitMask

            
        // If BombNode
        if (A == TankGamePhysicsCategory.Player || A == TankGamePhysicsCategory.Missile) && ( B == TankGamePhysicsCategory.Bomb){

            if let bombNode = contact.bodyB.node, let otherNode = contact.bodyB.node{
                if otherNode is missileNode {
                    otherNode.removeFromParent()
                }
                explodeBombNode(bombNode: (bombNode as! SKSpriteNode))
                
            }
        }
            
        else if (B == TankGamePhysicsCategory.Player || B == TankGamePhysicsCategory.Missile) && ( A == TankGamePhysicsCategory.Bomb){
            if let bombNode = contact.bodyA.node, let otherNode = contact.bodyB.node{
                if otherNode is missileNode{
                    otherNode.removeFromParent()
                }
                explodeBombNode(bombNode: (bombNode as! SKSpriteNode))
            }
        }
        
        
        
        // If A is missile and B is missile then both blowup
        else if (A == TankGamePhysicsCategory.Missile && B == TankGamePhysicsCategory.Missile) {
            if let missileA = contact.bodyA.node, let missileB = contact.bodyB.node {
                if (missileA.name == "JSON" && missileB.name == "JSON"){
                    missileA.removeFromParent()
                    missileB.removeFromParent()
                    self.createExplosion(position: missileA.position, scale: CGFloat(8.0), timePerFrame: 0.08)
                } else if (missileA.name == "JSON") {
                    self.createExplosion(position: missileB.position, scale: CGFloat(1.0), timePerFrame: 0.08)
                    missileB.removeFromParent()
                    
                } else if (missileB.name == "JSON") {
                    self.createExplosion(position: missileA.position, scale: CGFloat(1.0), timePerFrame: 0.08)
                    missileA.removeFromParent()
                } else {
                    self.createExplosion(position: missileA.position, scale: CGFloat(1.0), timePerFrame: 0.08)
                    missileA.removeFromParent()
                    missileB.removeFromParent()
                }
                
            }
        }
    
        else if (B == TankGamePhysicsCategory.Missile && A == TankGamePhysicsCategory.Player && !imminentReset) {
            if let player = contact.bodyA.node, let missile = contact.bodyB.node {
                var explosionScale = 2.5
                if (missile.name == "JSON"){explosionScale = 3.0}
                self.createExplosion(position: missile.position, scale: CGFloat(explosionScale), timePerFrame: 0.13)
                missile.removeFromParent()
                player.removeFromParent()
                
                self.imminentReset = true
                        
                self.run(.sequence([
                    .wait(forDuration: 1.0),
                    .run{[weak self] in
                        (player as! playerNode).decrementLives()
                        self?.checkEndgameConditions()
                        self?.resetOnHit()
                        
                }]))
                                
            }
        }
        
        // If B is missle and A is boundary, then decrease missile life by 1 or blowup if life == 0
    
        else if (B == TankGamePhysicsCategory.Missile && A == TankGamePhysicsCategory.Boundary) {
            if let missile = contact.bodyB.node{
                (missile as! missileNode).collide()
            }
        }
        
        // If the two bodies are a Player and a Powerup
        else if (B == TankGamePhysicsCategory.Powerup && A == TankGamePhysicsCategory.Player ) {
            if let powerup = contact.bodyB.node, let playerBody = contact.bodyA.node {
                handlePoweupPlayerContact(player: (playerBody as! playerNode), powerup: (powerup as! SKSpriteNode))
            }
        } else if(B == TankGamePhysicsCategory.Player && A == TankGamePhysicsCategory.Powerup) {
            if let powerup = contact.bodyA.node, let playerBody = contact.bodyB.node {
                handlePoweupPlayerContact(player: (playerBody as! playerNode), powerup: (powerup as! SKSpriteNode))
            }
        }
        
        
        else if(B == TankGamePhysicsCategory.Missile && A == TankGamePhysicsCategory.Powerup) {
            if let powerup = contact.bodyA.node, let missile = contact.bodyB.node {
                self.createExplosion(position: missile.position, scale: CGFloat(1.0), timePerFrame: 0.08)
                if(missile.name != "JSON"){missile.removeFromParent()}
                powerup.removeFromParent()
                powerupShadowNode.removeFromParent()
                activePowerup = nil
                
            }
            
            
            
        } else if(B == TankGamePhysicsCategory.Powerup && A == TankGamePhysicsCategory.Missile) {
            if let missile = contact.bodyA.node, let powerup = contact.bodyB.node {
                self.createExplosion(position: missile.position, scale: CGFloat(1.0), timePerFrame: 0.08)
                if(missile.name != "JSON"){missile.removeFromParent()}
                powerup.removeFromParent()
                powerupShadowNode.removeFromParent()
                activePowerup = nil
                
            }
        }
            
    }
    
}
