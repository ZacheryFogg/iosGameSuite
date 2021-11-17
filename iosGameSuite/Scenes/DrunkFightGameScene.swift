//
//  DrunkFightGameScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/15/21.
//

import SpriteKit
import GameplayKit

class DrunkFightGameScene: SKScene {
    
    //MARK: - Properties
    
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    
    var coin: SKSpriteNode!
    
    var cameraNode = SKCameraNode()
    
    var obstacles: [SKSpriteNode] = []
    
    var cameraMovePointPerSecond: CGFloat = 850.0
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var maxSpawnTime: CGFloat = 3.0
    
    var playerIsOnGround = true
    var playerVelocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var playerScore: Int = 0
    var isGameOver = false
    var life: Int = 3
    
    var lifeNodes: [SKSpriteNode] = []
    var scoreLabel = SKLabelNode(fontNamed: "rimouski sb")
    var coinIcon: SKSpriteNode!
    
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
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
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        // Calculate the display position of the camera
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)
        
        return CGRect(x: x, y: y, width: width, height:  height)
    }
    //MARK: - Systems
    override func didMove(to view: SKView) {
//        run(.sequence([
//            .wait(forDuration: 1.0),
//            .run { self.setupNodes()}
//        ]))
        self.setupNodes()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let node = atPoint(touch.location(in: self))
        
        if node.name == "pause" {
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
            
        } else if node.name == "resume" {
            containerNode.removeFromParent()
            isPaused = false
        } else if node.name == "quit" {
            
            let menuScene: SKScene = MenuScene(size: self.size)
            menuScene.scaleMode = .aspectFill
            
            self.view?.presentScene(menuScene)
            
        } else {
            if !isPaused {
                if playerIsOnGround {
                    playerIsOnGround = false
                    playerVelocityY = -25.0
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if playerVelocityY < -12.5 {
            playerVelocityY = -12.5
        }
        
    }
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        
        playerVelocityY += gravity
        player.position.y -= playerVelocityY
        
        if player.position.y < playerPosY {
            player.position.y = playerPosY
            playerVelocityY = 0.0
            playerIsOnGround = true
        }
    }
}

//MARK: - Configuration

extension DrunkFightGameScene {
    
    /* Initialize, configure, and add nodes as children to our scene*/
    func setupNodes(){
        createBackground()
        createGround()
        createPlayer()
        createCoin()
        
        spawnCoin()
        
        createObstacles()
        spawnObstacles()
        
        setupPhysics()
        
        setupPause()
        setupLife()
        setupScore()
        createCamera()
    }
    
    func setupPhysics(){
        physicsWorld.contactDelegate = self
    }
    
    
    func createBackground(){
        for i in 0...2{
            let background = SKSpriteNode(imageNamed: "background")
            background.name = "Background"
            // Default anchor point of a node is in center of screen (.5,.5), we need it to be bottom left (0,0)
            background.anchorPoint = .zero
            background.position = CGPoint(x: CGFloat(i) * background.frame.width, y: 0.0)
            background.zPosition = -1.0 // Make sure is appears behind other children
            self.addChild(background)
        }
    }
    
    func createGround(){
        // We want 3 grounds to allow ground to appear to be moving. As one ground off screen
        // it will then be added to the back of the queue so that it can reappear
        for i in 0...2 {
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            // Set position of each ground to be i x width, so that they are horizontally stacked
            ground.position = CGPoint(x: CGFloat(i) * ground.frame.width, y:0.0)
            
            // Add physics body
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.Ground
            self.addChild(ground)
        }
    }
    
    func createPlayer(){
        player = SKSpriteNode(imageNamed: "JSON1")
        player.name = "Player"
        player.zPosition = 5.0
        player.setScale(2.05)
        // This postions the player directly in contact with the ground and slightly to the left
        player.position = CGPoint(x: frame.width/2.0 - 100, y: ground.frame.height + player.frame.height/2.0)
        playerPosY = player.position.y
        
        // Add physics body to player
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2.0)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Block | PhysicsCategory.Coin
        self.addChild(player)
    }
    
    func createCoin() {
        coin = SKSpriteNode(imageNamed: "coin-1")
        coin.name = "Coin"
        let coinHeight = coin.frame.height
        let random = CGFloat.random(min: -coinHeight, max: coinHeight * 2.0)
        coin.position = CGPoint(x: cameraRect.maxX + coin.frame.width, y: size.height/2.0 + random)
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2.0)
        coin.physicsBody!.affectedByGravity = false
        coin.physicsBody!.isDynamic = false
        coin.physicsBody!.categoryBitMask = PhysicsCategory.Coin
        coin.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        addChild(coin)
        
        // Update this to despawn coin when it's off screen
        coin.run(.sequence([
            .wait(forDuration: 15.0),
            .removeFromParent()
        ]))
        
        // Animate Coin
        var textures: [SKTexture] = []
        for i in 1...6 {
            textures.append(SKTexture(imageNamed: "coin-\(i)"))
        }
        coin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.043)))
    }
    
    func createObstacles(){
        for i in 1...3 {
            let sprite = SKSpriteNode(imageNamed: "block-\(i)")
            sprite.name = "Block"
            obstacles.append(sprite)
        }
        
        for i in 1...2 {
            let sprite = SKSpriteNode(imageNamed: "obstacle-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
        }
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count - 1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.85)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0, y: ground.frame.height + sprite.frame.height/2.0)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.isDynamic = false
        
        if sprite.name == "Block" {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Block
        } else if sprite.name == "Obstacle" {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        }
        sprite.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        addChild(sprite)
        
        // Clean up nodes off camera.
        //TODO: This should be made intelligent to simply remove node when it is off screen bases on position
        sprite.run(.sequence([
            .wait(forDuration: 10.0),
            .removeFromParent()
        ]))
        
    }
    
    func createCamera() {
        self.addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera() {
        let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y:0.0)

        cameraNode.position += amountToMove

        // Loop Background
        enumerateChildNodes(withName: "Background") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width * 2.0, y: node.position.y)
            }
        }
        // Loop Ground
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width * 2.0, y: node.position.y)
            }
        }
    }
    
    func movePlayer(){
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        let rotate = CGFloat(1).degreesToRadians() * amountToMove/2.5  // formula = 1 degree * amountToMove/2.5
        player.zRotation -= rotate
        player.position.x += amountToMove

    }
    
    func spawnObstacles() {
        let random = Double(CGFloat.random(min: 1.5, max: maxSpawnTime))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.createObstacles()
            }
        ])))
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 5.0),
            .run {
                if (self.maxSpawnTime > 1.5){
                    self.maxSpawnTime -= 0.001
                }
            }
        ])))
    }
    
    func spawnCoin(){
        let random = CGFloat.random(min: 2.5, max: 6.0)
        run(.repeatForever(.sequence([
            .wait(forDuration: TimeInterval(random)),
            .run{ [weak self] in
                self?.createCoin()
            }
        ])))
    }
    
    func setupLife() {
        let node1 = SKSpriteNode(imageNamed: "life-on")
        let node2 = SKSpriteNode(imageNamed: "life-on")
        let node3 = SKSpriteNode(imageNamed: "life-on")
        
        setupLifePosition(node1, i: 1.0, j: 0.0)
        setupLifePosition(node2, i: 2.0, j: 8.0)
        setupLifePosition(node3, i: 3.0, j: 16.0)
        
        lifeNodes.append(node1)
        lifeNodes.append(node2)
        lifeNodes.append(node3)
    }
    
    func setupLifePosition(_ node: SKSpriteNode, i: CGFloat, j: CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        
        node.setScale(0.5)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width/2.0 + node.frame.width*i + j - 15.0,
                                y: height/2.0 - node.frame.height/2.0)
        
        cameraNode.addChild(node)
    }
    
    func setupScore() {
        coinIcon = SKSpriteNode(imageNamed: "coin-1")
        coinIcon.setScale(0.5)
        coinIcon.zPosition = 50.0
        coinIcon.position = CGPoint(x: -playableRect.width/2.0 + coinIcon.frame.width,
                                    y: playableRect.height/2.0 - lifeNodes[0].frame.height - coinIcon.frame.height/2.0)
        
        scoreLabel.text = "\(playerScore)"
        scoreLabel.fontSize = 60.0
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = 50.0
        scoreLabel.position = CGPoint(x: -playableRect.width/2.0 + coinIcon.frame.width*2.0 - 10.0,
                                      y: coinIcon.position.y + coinIcon.frame.height/2.0 - 8.0)
        
        cameraNode.addChild(coinIcon)
        cameraNode.addChild(scoreLabel)
    }
    
    func setupPause(){
        pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.setScale(0.5)
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        pauseNode.position = CGPoint(x: playableRect.width/2.0 - pauseNode.frame.width/2.0 - 30.0,
                                     y: playableRect.height/2.0 - pauseNode.frame.height/2.0 - 10.0)
        cameraNode.addChild(pauseNode)
    }
    
    func createPanel(){
        cameraNode.addChild(containerNode)
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale(0.7)
        resume.position = CGPoint(x: -panel.frame.width/2.0 + resume.frame.width * 1.5, y: 0.0)
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.setScale(0.7)
        quit.position = CGPoint(x: panel.frame.width/2.0 - quit.frame.width * 1.5, y: 0.0)
        panel.addChild(quit)
        
    }
    
    func decrementLife(){
        life -= 1
        if life <= 0 { life = 0}
        lifeNodes[life].texture = SKTexture(imageNamed: "life-off")
        
        if life <= 0 && !isGameOver {
            isGameOver = true
        }
    }
}

//MARK: - SKPhysicsContactDelegate

extension DrunkFightGameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
            
        case PhysicsCategory.Block:
            cameraMovePointPerSecond += 150.0
            playerScore-=1
            if playerScore <= 0 {
                playerScore = 0
            }
            scoreLabel.text = "\(playerScore)"
        case PhysicsCategory.Obstacle:
            decrementLife()
        case PhysicsCategory.Coin:
            if let node = other.node {
                node.removeFromParent()
                playerScore+=1
                scoreLabel.text = "\(playerScore)"
                if playerScore % 5 == 0{
                    cameraMovePointPerSecond += 100.00
                }
                
                let highscore = ScoreGenerator.sharedInstance.getHighscore()
                if playerScore > highscore {
                    ScoreGenerator.sharedInstance.setHighscore(playerScore)
                    ScoreGenerator.sharedInstance.setHighscore(highscore)
                }
            }
        default: break
        }
    }
}
