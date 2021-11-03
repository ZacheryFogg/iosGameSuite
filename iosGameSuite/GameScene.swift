//
//  GameScene.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 10/17/21.
//

import SpriteKit

class InfiniteJSONScene: SKScene {
    
    let JSON = SKSpriteNode(imageNamed: "JSON1")
    let JSON2 = SKSpriteNode(imageNamed: "JSON2" )
    let title = SKLabelNode(fontNamed: "Chalkduster")
    let score = SKLabelNode(fontNamed: "Chalkduster")
    var playerOneScore = 0
    var playerTwoScore = 0
    
    override func didMove(to view: SKView) { // This method is called as soon as the scene appears on screen
        
        //titles
        
        title.text = "Infinte JSON"
        title.fontSize = 45
        title.fontColor = SKColor.cyan
        //title position
        title.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        
        //score text
        score.text = String(playerOneScore) + " - " + String(playerTwoScore)
        //score position & design
        score.position = CGPoint(x: frame.midX, y: frame.minY + 50)
        score.fontSize = 20
        score.fontColor = SKColor.white
        
        //JSON position
        JSON.position = CGPoint(x:frame.midX, y:frame.midY)
        JSON2.position = CGPoint(x: frame.midX + 100, y: frame.midY + 100)
        
        //Physics
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame) // make frame of screen an immovable edge
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -3.0) // change gravity of the world
        JSON.physicsBody = SKPhysicsBody(texture: JSON.texture!, size: JSON.texture!.size()) // add a physics body to JSON
        JSON.physicsBody!.restitution = 1.2 // JSON will bounce back with a lot of force
        JSON.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 5.0)))
        
        JSON2.physicsBody = SKPhysicsBody(texture: JSON2.texture!, size: JSON2.texture!.size())
        JSON2.physicsBody!.restitution = 1.2
        JSON2.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 5.0)))
        
        addChild(JSON)
        addChild(JSON2)
        addChild(title)
        addChild(score)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        title.physicsBody = SKPhysicsBody(rectangleOf: title.frame.size)
        title.physicsBody!.restitution = 1.1
        addScorePlayerOne()
        updateScore()
    }
    
    //add score functions
    
    func addScorePlayerOne(){
        playerOneScore = 1 + playerOneScore
        updateScore()
    }
    
    
    func addScorePlayerTwo(){
        playerTwoScore = 1 + playerTwoScore
        updateScore()
    }
    
    //update score text
    
    func updateScore(){
        score.text = String(playerOneScore) + " - " + String(playerTwoScore)
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        texturedSpriteNode.run(SKAction.move(to: CGPoint(x: spriteNode.size.width, y: spriteNode.size.height), duration: 2.0 ))
////        texturedSpriteNode.run(SKAction.move(to: CGPoint(x: spriteNode.size.width, y: spriteNode.size.height), duration: 2.0)) {
////            self.texturedSpriteNode.position = CGPoint.zero
////        }
//        texturedSpriteNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 2.0)))
//
//        if !blueNode.hasActions() {
////            blueNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 2.0)))
//            blueNode.run(SKAction.group([SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 2.0), SKAction.scale(by: 0.9, duration: 2.0)]))
//        } else {
//            blueNode.removeAllActions()
//        }
//    }
}


