//
//  GameScene.swift
//  AirHockey
//
//  Created by Clayton Chisholm on 11/20/21.
//
import SpriteKit
import GameplayKit

class AHGameScene: SKScene {
    //variables 
    
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
    let quitButtonNodeName: String = "quitButtonNode"
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
    
    //didMove
    override func didMove(to view: SKView) {
        //objects
        puck = self.childNode(withName: "puck") as! SKSpriteNode
        player1 = self.childNode(withName: "player1") as! SKSpriteNode
        player2 = self.childNode(withName: "player2") as! SKSpriteNode
        //goals
        goalRed = self.childNode(withName: "GoalPlayer1") as! SKSpriteNode
        goalBlue = self.childNode(withName: "GoalPlayer2") as! SKSpriteNode
   
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
        //score display
        scorePlayer1Display.text = "\(scorePlayer1)"
        scorePlayer2Display.text = "\(scorePlayer2)"
        //scene
        createPauseButton()
        createCamera()
    }
    
    //create background
    func createBackground(){
        let background = SKSpriteNode(imageNamed: "airHockeyBackground")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1.0 // Make sure is appears behind other children
        addChild(background)
        
    }
    
    //touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        // Buttons in pause menu
        if node.name == pauseButtonNodeName {
            
            if isPaused {
                isPaused = false
                pauseContainerNode.removeFromParent()
            } else {
                createPausePanel()
                lastUpdateTime = 0.0
                dt = 0.0
                isPaused = true
            }
            
        } else if node.name == resumeButtonNodeName {
            pauseContainerNode.removeFromParent()
            isPaused = false
        } else if node.name == quitButtonNodeName {
            
            let menuScene: SKScene = MenuScene(size: CGSize(width: self.size.width / 2, height: self.size.height / 2))
            menuScene.scaleMode = .aspectFill
            
            self.view?.presentScene(menuScene, transition: .doorsCloseVertical(withDuration: 0.5))
        }
        // Buttons in post game menu
        else if node.name == replayButtonNodeName {
            let newGameScene = SKScene(fileNamed: "AHGameScene")!// AHGameScene(size: self.size)
            newGameScene.scaleMode = .aspectFill
            self.view?.presentScene(newGameScene, transition: .doorsOpenVertical(withDuration: 0.5))
        
        } else if node.name == quitButtonNodeName {
            let menuScene: SKScene = MenuScene(size: CGSize(width: self.size.width / 2, height: self.size.height / 2))
            menuScene.scaleMode = .aspectFill
            
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
    
    
    //ball at start of game 
    func randomStart(){
        puck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        
    }
    
    //movements for both players
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            let location = touch.location(in: self)
            //player 1 vs. player 2 movement
            if location.x > 0{
                player2.run(SKAction.move(to: location, duration: 0.2))
            }
            if location.x < 0{
                player1.run(SKAction.move(to: location, duration: 0.2))
            }
            
            
        }
    }
    
    //create Camera
    func createCamera() {
        self.addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    //create pause button
    func createPauseButton(){
        pauseButtonNode = SKSpriteNode(imageNamed: "pause")
        pauseButtonNode.setScale(0.16)
        pauseButtonNode.zPosition = 50.0
        pauseButtonNode.name = pauseButtonNodeName
        pauseButtonNode.position = CGPoint(x: 0.0 - self.size.width/2 + pauseButtonNode.frame.width/2 + 10.0, y: self.frame.maxY - pauseButtonNode.frame.height/2 - 10.0)
        self.addChild(pauseButtonNode)
    }
    
    /*
     Create pause panel when pause button pushed
     */
    func createPausePanel(){
        //menu
        let menuScale = 0.16       
        pauseContainerNode.position = CGPoint(x: 0, y: 0)
        self.addChild(pauseContainerNode)
        
        //pause panel
        let pauseGamePanel = SKSpriteNode(imageNamed: "panel")
        pauseGamePanel.size = CGSize(width: self.frame.width/2.0, height: self.frame.width/4.0)
        pauseGamePanel.zPosition = 60.0
        pauseContainerNode.addChild(pauseGamePanel)
        //pause title
        let pauseGamePanelTitle = SKLabelNode(fontNamed: "American Typewriter")
        pauseGamePanelTitle.text = "Game Paused"
        pauseGamePanelTitle.zPosition = 80.0
        pauseGamePanelTitle.fontSize = 60
        pauseGamePanelTitle.fontColor = SKColor.white
        pauseGamePanelTitle.position = CGPoint(x: pauseGamePanel.frame.midX, y: pauseGamePanel.frame.maxY - 90.0)
        pauseGamePanel.addChild(pauseGamePanelTitle)
        
        //replay button
        let replayButton = SKSpriteNode(imageNamed: "replay")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(menuScale)
        replayButton.position = CGPoint(x: pauseGamePanel.frame.midX - (replayButton.frame.width * 1.4), y:pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(replayButton)
        
        //quit button
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitButtonNodeName
        quitButton.setScale(menuScale)
        quitButton.position = CGPoint(x: pauseGamePanel.frame.midX + (quitButton.frame.width * 1.4) , y: pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(quitButton)
        
        //resume button
        let resumeButton = SKSpriteNode(imageNamed: "resume")
        resumeButton.zPosition = 70.0
        resumeButton.name = resumeButtonNodeName
        resumeButton.setScale(menuScale * 1.5)
        resumeButton.position = CGPoint(x: pauseGamePanel.frame.midX , y: pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(resumeButton)
    }
    
    /*
     Create post game menu when game is over
     */
    func createPostGamePanel(){
        let menuScale = 0.4
        
        postGameContainerNode.position = CGPoint(x: 0, y: 0)
        self.addChild(postGameContainerNode)
       
        //post game panel
        let postGamePanel = SKSpriteNode(imageNamed: "panel")
        postGamePanel.size = CGSize(width: self.frame.width/1.8, height: self.frame.width/4.0)
        postGamePanel.zPosition = 60.0
        postGameContainerNode.addChild(postGamePanel)
        
        let postGamePanelTitle = SKLabelNode(fontNamed: "AmericanTypewriter")
        if scorePlayer1 > 4 {
            postGamePanelTitle.text = "Game Over: Red wins! "
        } else  {
            postGamePanelTitle.text = "Game Over: Blue Wins!"
        }
        
        //position
        postGamePanelTitle.zPosition = 80.0
        postGamePanelTitle.fontSize = 60
        postGamePanelTitle.fontColor = SKColor.white
        //post game title
        postGamePanelTitle.position = CGPoint(x: postGamePanel.frame.midX, y: postGamePanel.frame.maxY - 90.0)
        postGamePanel.addChild(postGamePanelTitle)
        
        //replay button
        let replayButton = SKSpriteNode(imageNamed: "replay")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(menuScale * 0.56)
        replayButton.position = CGPoint(x: postGamePanel.frame.midX - replayButton.frame.width, y:postGamePanel.frame.midY - 20.0)
        postGamePanel.addChild(replayButton)
        
        //quit button
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitButtonNodeName
        quitButton.setScale(menuScale * 0.56)
        quitButton.position = CGPoint(x: postGamePanel.frame.midX + quitButton.frame.width , y: postGamePanel.frame.midY - 20.0)
        postGamePanel.addChild(quitButton)
    }

    //add score player one 
    func addScorePlayerOne(){
        //add score to player one
        scorePlayer1 = scorePlayer1 + 1
        scorePlayer1Display.text = "\(scorePlayer1)"
        if scorePlayer1 == 5{
            createPostGamePanel()
            isPaused = true
        } else{
        //launch puck
        puck.position = CGPoint(x: 100, y: 0)
        puck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
    }
    
    //add score player two
    func addScorePlayerTwo(){
        //add score to player two
        scorePlayer2 = scorePlayer2 + 1
        scorePlayer2Display.text = "\(scorePlayer2)"
        if scorePlayer2 == 5{
            createPostGamePanel()
            isPaused = true
        }else{
        //launch puck
        puck.position = CGPoint(x: -100, y: 0)
        puck.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
    }
    
    //update
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
            self.run(.sequence([
                .wait(forDuration: 1.5),
                .run { [weak self] in
                    self?.addScorePlayerOne()
                }
            ]))

        }
        
    }
    
}
