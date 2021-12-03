//
//  GameScene.swift
//  AirHockey
//
//  Created by Clayton Chisholm on 11/20/21.
//

import SpriteKit
import GameplayKit

class AHGameScene: SKScene {
    //objects
    var puck = SKSpriteNode()
    var player1 = SKSpriteNode()
    var player2 = SKSpriteNode()
    //score
    var scorePlayer1 = 0
    var scorePlayer2 = 0
    //score display
    var scorePlayer1Display = SKLabelNode()
    var scorePlayer2Display = SKLabelNode()
    
    
    override func didMove(to view: SKView) {
        //objects
        puck = self.childNode(withName: "puck") as! SKSpriteNode
        player1 = self.childNode(withName: "player1") as! SKSpriteNode
        player2 = self.childNode(withName: "player2") as! SKSpriteNode
        
        //background
        //let background = SKSpriteNode(imageNamed: "CheckIcon")
        //background.size = frame.size
        //background.position = CGPoint(x: frame.midX, y: frame.midY)
        //addChild(background)
        
        //player spawn for different screen sizes
        player1.position.x = (self.frame.height/2) + 120
        player1.position.x = (-self.frame.height/2) - 120
        
        //score
        scorePlayer1Display = self.childNode(withName: "player1ScoreDisplay") as! SKLabelNode
        scorePlayer2Display = self.childNode(withName: "player2ScoreDisplay") as! SKLabelNode
        
        //ball goes in random direction for start of game
        randomStart()
        
        //border
        let border  = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        //start game
        start()

    }
    
    func start() {
        //reset score when starts
        scorePlayer1 = 0
        scorePlayer2 = 0
        scorePlayer1Display.text = "\(scorePlayer1)"
        scorePlayer2Display.text = "\(scorePlayer2)"
    }
    
    
    //touches began to get touch input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            player1.run(SKAction.moveTo(y: location.y, duration: 0.2))
        }
        
    }
    //make ball go in random direction
    func randomStart(){
        //make random when game starts
        let xImpulse = Int.random(in: -20..<21)
        let yImpulse = Int.random(in: -20..<21)
        puck.physicsBody?.applyImpulse(CGVector(dx: xImpulse, dy: yImpulse))
        
    }
    //movements for both players
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            //player 1 vs. player 2 movement
            if location.x > 0{
                //player2.run(SKAction.moveTo(y: location.y, duration: 0.2))
                player2.run(SKAction.move(to: location, duration: 0.2))
            }
            if location.x < 0{
                player1.run(SKAction.move(to: location, duration: 0.2))
            }
            
            
        }
    }
    
    func addScorePlayerOne(){
        //add score to player one
        scorePlayer1 = scorePlayer1 + 1
        print(scorePlayer1)
        scorePlayer1Display.text = "\(scorePlayer1)"
        //launch puck
        puck.position = CGPoint(x: 0, y: 0)
        puck.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
        
        
        
    }
    
    func addScorePlayerTwo(){
        //add score to player two
        scorePlayer2 = scorePlayer2 + 1
        print(scorePlayer2)
        scorePlayer2Display.text = "\(scorePlayer2)"
        //launch puck 
        puck.position = CGPoint(x: 0, y: 0)
        let start = Int.random(in: 0..<2)
        if start == 1{
            puck.physicsBody?.applyImpulse(CGVector(dx: -20, dy: -20))
        }else{
            puck.physicsBody?.applyImpulse(CGVector(dx: -20, dy: 20))
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //score
        //if ball hits left side of the screen
        if puck.position.x <= (-self.frame.height) + 120{
            //reset with no force
            puck.position = CGPoint(x: 0, y: 0)
            puck.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            //add score
            addScorePlayerTwo()
        }
        
        //if ball hits right side of the screen
        if puck.position.x >= (self.frame.height) - 120{
            //reset with no force
            puck.position = CGPoint(x: 0, y: 0)
            puck.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            addScorePlayerOne()
        }
        
    }
}
