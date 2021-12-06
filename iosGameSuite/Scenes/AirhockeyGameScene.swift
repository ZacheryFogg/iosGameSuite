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
    //goals
    var goalRed = SKSpriteNode()
    var goalBlue = SKSpriteNode()
    
    //buttons
    var pauseButtonNode: SKSpriteNode!
    var pauseContainerNode = SKNode()
    var postGameContainerNode = SKNode()
    
    // Names for nodes declared globally so that they can be easily changed
    let pauseButtonNodeName: String = "pauseButtonNode"
    let resumeButtonNodeName: String = "resumeButtonNode"
    let quitFromPauseButtonNodeName: String = "quitFromPauseButtonNode"
    let quitFromPostButtonNodeName: String = "quitFromPostButtonNode"
    let replayButtonNodeName: String = "replayButtonNode"
    
    //camera
    var cameraNode = SKCameraNode()
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    //playrec
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
    
    
    override func didMove(to view: SKView) {
        //objects
        puck = self.childNode(withName: "puck") as! SKSpriteNode
        player1 = self.childNode(withName: "player1") as! SKSpriteNode
        player2 = self.childNode(withName: "player2") as! SKSpriteNode
        //goals
        goalRed = self.childNode(withName: "GoalPlayer1") as! SKSpriteNode
        goalBlue = self.childNode(withName: "GoalPlayer2") as! SKSpriteNode
        
        //background
        
        
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
        //background
        createBackground()
        //reset score when starts
        scorePlayer1 = 0
        scorePlayer2 = 0
        scorePlayer1Display.text = "\(scorePlayer1)"
        scorePlayer2Display.text = "\(scorePlayer2)"
        //pause
        setupPauseButton()
        createCamera()
    }
    
    func createBackground(){
        let background = SKSpriteNode(imageNamed: "airHockeyBackground")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1.0 // Make sure is appears behind other children
        addChild(background)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let node = atPoint(touch.location(in: self))
        
        // Buttons in pause menu
        if node.name == pauseButtonNodeName{
            if isPaused { return }
            createPausePanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
            
        } else if node.name == resumeButtonNodeName {
            pauseContainerNode.removeFromParent()
            isPaused = false
        } else if node.name == quitFromPauseButtonNodeName {
            
            let menuScene: SKScene = MenuScene(size: CGSize(width: self.size.width / 3, height: self.size.height / 3))
            menuScene.scaleMode = self.scaleMode
            
            self.view?.presentScene(menuScene, transition: .doorsCloseVertical(withDuration: 0.5))
        }
        // Buttons in post game menu
        else if node.name == replayButtonNodeName {
            let newGameScene = AHGameScene(size: self.size)
            newGameScene.scaleMode = self.scaleMode
            self.view?.presentScene(newGameScene, transition: .doorsOpenVertical(withDuration: 0.5))
        
        } else if node.name == quitFromPostButtonNodeName {
            let menuScene: SKScene = MenuScene(size: CGSize(width: self.size.width / 3, height: self.size.height / 3))
            menuScene.scaleMode = self.scaleMode
            
            self.view?.presentScene(menuScene, transition: .doorsCloseVertical(withDuration: 0.5))

        }
        // Touch was not a button, jump player
        else {
            if !isPaused {
                for touch in touches {
                    let location = touch.location(in: self)
                    player1.run(SKAction.moveTo(y: location.y, duration: 0.2))
                    }
                }
            }
        }
    
    
    
    //touches began to get touch input
    //make ball go in random direction
    func randomStart(){
        puck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        
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
    
    func createPausePanel(){
        cameraNode.addChild(pauseContainerNode)
        
        let pausePanel = SKSpriteNode(imageNamed: "panel")
        pausePanel.zPosition = 60.0
        pausePanel.position = .zero
        pauseContainerNode.addChild(pausePanel)
        
        let resumeButton = SKSpriteNode(imageNamed: "resume")
        resumeButton.zPosition = 70.0
        resumeButton.name = resumeButtonNodeName
        resumeButton.setScale(0.35)
        resumeButton.position = CGPoint(x: -pausePanel.frame.width/2.0 + resumeButton.frame.width * 1.1, y: 0.0)
        pausePanel.addChild(resumeButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitFromPauseButtonNodeName
        quitButton.setScale(0.35)
        quitButton.position = CGPoint(x: pausePanel.frame.width/2.0 - quitButton.frame.width * 1.1, y: 0.0)
        pausePanel.addChild(quitButton)
        
    }
    
    func createCamera() {
        self.addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func setupPauseButton(){
        pauseButtonNode = SKSpriteNode(imageNamed: "pause")
        pauseButtonNode.setScale(0.1)
        pauseButtonNode.zPosition = 50.0
        pauseButtonNode.name = pauseButtonNodeName
        pauseButtonNode.position = CGPoint(x: playableRect.width/2.0 - pauseButtonNode.frame.width/2.0 - 30.0,
                                     y: playableRect.height/2.0 - pauseButtonNode.frame.height/2.0 - 10.0)
        cameraNode.addChild(pauseButtonNode)
    }
    
    func createPostGamePanel(){
        cameraNode.addChild(postGameContainerNode)
        
        // Image will need to change for all of these
        let postGamePanel = SKSpriteNode(imageNamed: "panel")
        postGamePanel.zPosition = 60.0
//        postGamePanel.setScale(2.0)
        postGamePanel.position = .zero // middle of screen I think
        postGameContainerNode.addChild(postGamePanel)
        
        let postGamePanelTitle = SKLabelNode(fontNamed: "rimouski sb")
        if scorePlayer1 > 4 {
            postGamePanelTitle.text = "Game Over: Red wins! "
        } else  {
            postGamePanelTitle.text = "Game Over: Blue Wins!"
        }
        postGamePanelTitle.fontSize = 70
        postGamePanelTitle.fontColor = SKColor.black
        postGamePanelTitle.position = CGPoint(x: postGamePanel.frame.midX, y: postGamePanel.frame.height/2.0 + 50)
        postGamePanel.addChild(postGamePanelTitle)
        
        let postGamePanelMessage = SKLabelNode(fontNamed: "rimouski sb")
//        postGamePanelMessage.text = "\(snakeRed.count) - \(snakeBlue.count)"
        postGamePanelMessage.fontSize = 60
        postGamePanelMessage.fontColor = SKColor.white
        postGamePanelMessage.position = CGPoint(x: postGamePanel.frame.midX, y: postGamePanel.frame.height/2.0 + 5)
        postGamePanel.addChild(postGamePanelMessage)
        
        let replayButton = SKSpriteNode(imageNamed: "replay")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(0.35)
        replayButton.position = CGPoint(x: -postGamePanel.frame.width/2.0 + replayButton.frame.width * 1.1, y:0.0)
        postGamePanel.addChild(replayButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitFromPostButtonNodeName
        quitButton.setScale(0.35)
        quitButton.position = CGPoint(x: postGamePanel.frame.width/2.0 - quitButton.frame.width * 1.1, y: 0.0)
        postGamePanel.addChild(quitButton)
        
        
    }

    
    func addScorePlayerOne(){
        //add score to player one
        scorePlayer1 = scorePlayer1 + 1
        print(scorePlayer1)
        scorePlayer1Display.text = "\(scorePlayer1)"
        if scorePlayer1 == 5{
            print("Player 1 win")
            createPostGamePanel()
            isPaused = true
        } else{
        //launch puck
        puck.position = CGPoint(x: 100, y: 0)
        puck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
    }
    
    
    func addScorePlayerTwo(){
        //add score to player two
        scorePlayer2 = scorePlayer2 + 1
        print(scorePlayer2)
        scorePlayer2Display.text = "\(scorePlayer2)"
        if scorePlayer2 == 5{
            print("player 2 win")
            createPostGamePanel()
            isPaused = true
        }else{
        //launch puck 
        puck.position = CGPoint(x: -100, y: 0)
        puck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
    }
    
    

    
   
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //score
        //if ball hits left side of the screen
        if puck.position.x <= -(self.frame.height) + 125 && puck.position.y < 0 + (goalRed.size.height/2) && puck.position.y > -(goalRed.size.height/2){
            //reset with no force
            puck.position = CGPoint(x: 0, y: 0)
            puck.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
            //add score
            self.run(.sequence([
                .wait(forDuration: 1.5),
                .run { [weak self] in
                    self?.addScorePlayerTwo()
                }
            ]))
            
            //isPaused = true
        }
        
        //if ball hits right goal
        if puck.position.x >= (self.frame.height) - 120 && puck.position.y < 160 && puck.position.y > -160{
            //reset with no force
            puck.position = CGPoint(x: 0, y: 0)
            puck.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
//            addScorePlayerOne()
            self.run(.sequence([
                .wait(forDuration: 1.5),
                .run { [weak self] in
                    self?.addScorePlayerOne()
                }
            ]))

        }
        
    }
    
}
