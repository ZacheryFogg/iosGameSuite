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
    var cameraNode = SKCameraNode()
    
    var obstacles: [SKSpriteNode] = []
    
    var cameraMovePointPerSecond: CGFloat = 650.0
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var maxSpawnTime: CGFloat = 3.0
    
    var playerOnGround = true
    var playerVelocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
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
        
    }
}

//MARK: - Configuration

extension DrunkFightGameScene {
    
    /* Initialize, configure, and add nodes as children to our scene*/
    func setupNodes(){
        createBackground()
        createGround()
        createPlayer()
        setupObstacles()
        spawnObstacles()
        setupCamera()
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
            self.addChild(ground)
        }
    }
    
    func createPlayer(){
        player = SKSpriteNode(imageNamed: "ninja")
        player.name = "Player"
        player.zPosition = 5.0
        player.setScale(0.85)
        // This postions the player directly in contact with the ground and slightly to the left
        player.position = CGPoint(x: frame.width/2.0 - 100, y: ground.frame.height + player.frame.height/2.0)
        playerPosY = player.position.y
        self.addChild(player)
    }
    
    func setupObstacles(){
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
        addChild(sprite)
        
        // Clean up nodes off camera.
        //TODO: This should be made intelligent to simply remove node when it is off screen bases on position
        sprite.run(.sequence([
            .wait(forDuration: 10.0),
            .removeFromParent()
        ]))
        
    }
    
    func setupCamera() {
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
                self?.setupObstacles()
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
    
}
