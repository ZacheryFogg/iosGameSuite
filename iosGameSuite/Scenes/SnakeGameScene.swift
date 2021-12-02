//
//  SnakeGameScene.swift
//  iosGameSuite
//
//  Created by Kevin Veronneau on 11/24/21.
//

import SpriteKit

class SnakeGameScene: SKScene {
    let snakeSize = CGSize(width: 75, height: 75)
    let pelletSize = CGSize(width: 50, height: 50)
    let startingSize = 5
    let maxPellets = 100
    var snakeBlue: [SKSpriteNode] = []
    var snakeRed: [SKSpriteNode] = []
    
    var collidedBlue = false
    var collidedRed = false
    
//    var directionBlue = Direction.left
//    var directionRed = Direction.right
    
    var directionBlue = Direction.down
    var directionRed = Direction.down
    
    
    var pointPellets: [SKSpriteNode] = []
    
    //MARK: - Properties
    
    // controls snake speed number represents blocks/second
    let refreshRate = 0.5
    
    var cameraNode = SKCameraNode()
    
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var isGameOver = false
    
    var scoreLabel = SKLabelNode(fontNamed: "rimouski sb")
    
    var pauseButtonNode: SKSpriteNode!
    var pauseContainerNode = SKNode()
        
    var upButtonBlueNode: SKSpriteNode!
    var downButtonBlueNode: SKSpriteNode!
    var leftButtonBlueNode: SKSpriteNode!
    var rightButtonBlueNode: SKSpriteNode!
    
    var upButtonRedNode: SKSpriteNode!
    var downButtonRedNode: SKSpriteNode!
    var leftButtonRedNode: SKSpriteNode!
    var rightButtonRedNode: SKSpriteNode!
    
    var buttonContainerBlue = SKNode()
    var buttonContainerRed = SKNode()
    
    let arrowButtonSize = CGSize(width: 125, height: 125)
    
    var postGameContainerNode = SKNode()
    
    
    // Names for nodes declared globally so that they can be easily changed
    let pauseButtonNodeName: String = "pauseButtonNode"
    let resumeButtonNodeName: String = "resumeButtonNode"
    let quitFromPauseButtonNodeName: String = "quitFromPauseButtonNode"
    let quitFromPostButtonNodeName: String = "quitFromPostButtonNode"
    let replayButtonNodeName: String = "replayButtonNode"
    
    let upButtonBlueNodeName: String = "upButtonBlueNode"
    let downButtonBlueNodeName: String = "downButtonBlueNode"
    let leftButtonBlueNodeName: String = "leftButtonBlueNode"
    let rightButtonBlueNodeName: String = "rightButtonBlueNode"
    
    let upButtonRedNodeName: String = "upButtonRedNode"
    let downButtonRedNodeName: String = "downButtonRedNode"
    let leftButtonRedNodeName: String = "leftButtonRedNode"
    let rightButtonRedNodeName: String = "rightButtonRedNode"
    
    var playableRect = UIScreen.main.bounds
    
//    var playableRect: CGRect {
//        let ratio: CGFloat
//        switch UIScreen.main.nativeBounds.height {
//
//        case 2688,1792,2436:
//            ratio = 2.16
//        default:
//            ratio = 16/9
//        }
//
//        let playableHeight = self.size.width / ratio
//        let playableMargin = (self.size.height - playableHeight) / 2.0
//        return CGRect(x: 0.0, y: playableMargin, width: self.size.width, height: playableHeight)
//    }
    
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
            
            let menuScene: SKScene = MenuScene(size: self.size)
            menuScene.scaleMode = self.scaleMode
            
            self.view?.presentScene(menuScene, transition: .doorsCloseVertical(withDuration: 0.5))
        }
        // Movement control buttons
        else if node.name == upButtonBlueNodeName {
            directionBlue = Direction.up
        } else if node.name == downButtonBlueNodeName {
            directionBlue = Direction.down
        } else if node.name == leftButtonBlueNodeName {
            directionBlue = Direction.left
        } else if node.name == rightButtonBlueNodeName {
            directionBlue = Direction.right
        } else if node.name == upButtonRedNodeName {
            directionRed = Direction.up
        } else if node.name == downButtonRedNodeName {
            directionRed = Direction.down
        } else if node.name == leftButtonRedNodeName {
            directionRed = Direction.left
        } else if node.name == rightButtonRedNodeName {
            directionRed = Direction.right
        }
        // Buttons in post game menu
        else if node.name == replayButtonNodeName {
            let newGameScene = SnakeGameScene(size: self.size)
            newGameScene.scaleMode = self.scaleMode
            self.view?.presentScene(newGameScene, transition: .doorsOpenVertical(withDuration: 0.5))
        
        } else if node.name == quitFromPostButtonNodeName {
            let menuScene: SKScene = MenuScene(size: self.size)
            menuScene.scaleMode = self.scaleMode
            
            self.view?.presentScene(menuScene, transition: .doorsCloseVertical(withDuration: 0.5))

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
    }
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime >= 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        if dt > refreshRate {
            lastUpdateTime = currentTime
            moveSnake(snakeBlue)
            moveSnake(snakeRed)
            checkSnakeCollisions()
            if collidedBlue || collidedRed {
                isGameOver = true
            }
            checkPelletPickup()
//            relocatePellet(pointPellets[0])
        }

        
        if isGameOver {
            // Present out game over scene, with possibly
            if !isPaused{
                createPostGamePanel()
                isPaused = true
            }
        }
    }
}

// MARK: - Configuration
extension SnakeGameScene {
    
    /* Initialize, configure, and add nodes as children to our scene*/
    func setupNodes(){
        createBackground()
        createSnakes()
        
        setupArrowButtons()
        
        createPointPellets()
        
        setupPauseButton()
        setupScore()
        
        createCamera()
    }
    
    func createBackground(){
        let background = SKSpriteNode(imageNamed: "snakeBackground")
        background.name = "Background"
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size = CGSize(width: self.size.width, height: playableRect.height)
        background.zPosition = -1.0 // Make sure is appears behind other children
        self.addChild(background)
    }

    
    func createSnakes(){

        for i in 0..<startingSize {
            let snakeBody = SKSpriteNode(imageNamed: "snakeBodyBlue")
            snakeBody.name = "SnakeBodyBlue"
            // Default anchor point of a node is in center of screen (.5,.5), we need it to be bottom left (0,0)
//            snakeBody.anchorPoint = .zero
            snakeBody.position = CGPoint(x: playableRect.width/2 + (4 + CGFloat(i)) * snakeSize.width, y: playableRect.height/2)
            snakeBody.size = snakeSize
            snakeBody.zPosition = 51.0 // Above pause button but under controls
            self.addChild(snakeBody)
            snakeBlue.append(snakeBody)
        }
        
        for i in 0..<startingSize {
            let snakeBody = SKSpriteNode(imageNamed: "snakeBodyRed")
            snakeBody.name = "SnakeBodyRed"
            // Default anchor point of a node is in center of screen (.5,.5), we need it to be bottom left (0,0)
//            snakeBody.anchorPoint = .zero
            snakeBody.position = CGPoint(x: playableRect.width/2 - (4 + CGFloat(i)) * snakeSize.width, y: playableRect.height/2)
            snakeBody.size = snakeSize
            snakeBody.zPosition = 51.0 // Above pause button but under controls
            self.addChild(snakeBody)
            snakeRed.append(snakeBody)
        }
    }
    
    func moveSnake(_ snake: [SKSpriteNode]) {
        let headPosition = snake[0].position
        var oldPosition: CGPoint
        var newPosition = snake[0].position

        // figure out which way its going and set the coefficient
        var leftRight = 0
        var upDown = 0
        
        // determine which snake we have so we know which to update
        var snakeDirection = directionRed
        if snake[0].name == "SnakeBodyBlue" {
            snakeDirection = directionBlue
        }

        
        
        switch snakeDirection {
        case Direction.up:
            upDown = 1
        case Direction.down:
            upDown = -1
        case Direction.left:
            leftRight = -1
        case Direction.right:
            leftRight = 1
        }
        snake[0].position = CGPoint(x: headPosition.x + snakeSize.width * CGFloat(leftRight), y: headPosition.y + snakeSize.width * CGFloat(upDown))
        for i in 1..<snake.count {
            oldPosition = snake[i].position
            if oldPosition == newPosition {
                continue
            }
            snake[i].position = newPosition
            newPosition = oldPosition
        }
    }
    
    func createPointPellets() {
        for _ in 0..<maxPellets {
            let pointPellet = SKSpriteNode(imageNamed: "snakePointPellet")
            pointPellet.name = "pointPellet"
            pointPellet.position = CGPoint(x: playableRect.width/2 + snakeSize.width * 0, y: playableRect.height/2 + snakeSize.height * 0)
            pointPellet.size = pelletSize
            pointPellet.zPosition = 56.0
            self.addChild(pointPellet)
            pointPellets.append(pointPellet)
            relocatePellet(pointPellet)
        }
    }
    
    func checkSnakeCollisions() {
        // check for head collision into either snake and itself
        for node in snakeRed {
            if snakeBlue[0].position == node.position {
                collidedBlue = true
            }
        }
        for i in 1..<snakeBlue.count {
            if snakeBlue[0].position == snakeBlue[i].position {
                collidedBlue = true
            }
        }
        
        for node in snakeBlue {
            if snakeRed[0].position == node.position {
                collidedRed = true
            }
        }
        for i in 1..<snakeRed.count {
            if snakeRed[0].position == snakeRed[i].position {
                collidedRed = true
            }
        }
        
        if collidedBlue {
            for node in snakeBlue {
                node.texture = SKTexture(imageNamed: "snakeBodyDead")
                node.name = "SnakeBodyBlueDead"
            }
        }
        if collidedRed {
            for node in snakeRed {
                node.texture = SKTexture(imageNamed: "snakeBodyDead")
                node.name = "SnakeBodyRedDead"
            }
        }

    }
    
    func checkPelletPickup() {
        for pellet in pointPellets {
            if snakeBlue[0].position == pellet.position {
                addSnakeNodes(to: snakeBlue, numNodes: 3)
                relocatePellet(pellet)
            }
            if snakeRed[0].position == pellet.position {
                addSnakeNodes(to: snakeRed, numNodes: 3)
                relocatePellet(pellet)
            }
        }
    }
    
    func relocatePellet(_ pellet: SKSpriteNode) {
        // while invalid location
        var locationInvalid = true
        var maxHeight = 0
        var minHeight = 0
        var maxWidth = 0
        var minWidth = 0
        
        while playableRect.width/2 + snakeSize.width * CGFloat(maxWidth) < playableRect.width {
            maxWidth += 1
        }
        while playableRect.width/2 + snakeSize.width * CGFloat(minWidth) > 0 {
            minWidth -= 1
        }
        while playableRect.height/2 + snakeSize.height * CGFloat(maxHeight) < playableRect.height {
            maxHeight += 1
        }
        while playableRect.height/2 + snakeSize.height * CGFloat(minHeight) > 0 {
            minHeight -= 1
        }
        
        print("minH: \(minHeight), maxH: \(maxHeight), minW: \(minWidth), maxW: \(maxWidth)")
        while locationInvalid {
            locationInvalid = false
            // put in playable rect

            
            pellet.position = CGPoint(x: playableRect.width/2 + snakeSize.width * CGFloat(Int.random(in: minWidth...maxWidth)), y: playableRect.height/2 + snakeSize.height * CGFloat(Int.random(in: minHeight...maxHeight)))
            
            // don't put on top of another pellet
            for p in pointPellets {
                if p != pellet && pellet.intersects(p) {
                    locationInvalid = true
                }
            }
            // don't put in a snake
            for snakeNode in snakeBlue {
                if pellet.intersects(snakeNode) {
                    locationInvalid = true
                }
            }
            for snakeNode in snakeRed {
                if pellet.intersects(snakeNode) {
                    locationInvalid = true
                }
            }
            // don't put on controls
            if pellet.intersects(upButtonBlueNode) || pellet.intersects(downButtonBlueNode) || pellet.intersects(leftButtonBlueNode) || pellet.intersects(rightButtonBlueNode) || pellet.intersects(upButtonRedNode) || pellet.intersects(downButtonRedNode) || pellet.intersects(leftButtonRedNode) || pellet.intersects(rightButtonRedNode) {
                locationInvalid = true
            }
        }
    }
    
    func addSnakeNodes(to snake: [SKSpriteNode], numNodes: Int) {
        let lastNodePos = snake[snake.count - 1].position
        var snakeImageName = "snakeBodyRed"
        if snake[0].name == "SnakeBodyBlue" {
            snakeImageName = "snakeBodyBlue"
        }
        
        for _ in 0..<numNodes {
            let snakeBody = SKSpriteNode(imageNamed: snakeImageName)
            snakeBody.name = snake[0].name
            // Default anchor point of a node is in center of screen (.5,.5), we need it to be bottom left (0,0)
//            snakeBody.anchorPoint = .zero
            snakeBody.position = lastNodePos
            snakeBody.size = snakeSize
            snakeBody.zPosition = 51.0 // Above pause button but under controls
            self.addChild(snakeBody)
            if snake[0].name == "SnakeBodyBlue" {
                snakeBlue.append(snakeBody)
            } else {
                snakeRed.append(snakeBody)
            }
        }
        
    }
    
    func createCamera() {
        self.addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func setupScore() {
        
//        scoreLabel.text = "\(playerScore)"
        scoreLabel.fontSize = 60.0
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = 50.0
//        scoreLabel.position = CGPoint(x: -playableRect.width/2.0 + coinIcon.frame.width*2.0 - 10.0,
//                                      y: coinIcon.position.y + coinIcon.frame.height/2.0 - 8.0)
        
        cameraNode.addChild(scoreLabel)
    }
    
    func setupPauseButton(){
        pauseButtonNode = SKSpriteNode(imageNamed: "pause")
        pauseButtonNode.setScale(0.5)
        pauseButtonNode.zPosition = 50.0
        pauseButtonNode.name = pauseButtonNodeName
        pauseButtonNode.position = CGPoint(x: playableRect.width/2.0 - pauseButtonNode.frame.width/2.0 - 30.0,
                                     y: playableRect.height/2.0 - pauseButtonNode.frame.height/2.0 - 10.0)
        cameraNode.addChild(pauseButtonNode)
    }
    
    func setupArrowButtons() {
        upButtonBlueNode = SKSpriteNode(imageNamed: "arrowButtonBlue")
        downButtonBlueNode = SKSpriteNode(imageNamed: "arrowButtonBlue")
        leftButtonBlueNode = SKSpriteNode(imageNamed: "arrowButtonBlue")
        rightButtonBlueNode = SKSpriteNode(imageNamed: "arrowButtonBlue")
        
        upButtonBlueNode.size = arrowButtonSize
        downButtonBlueNode.size = arrowButtonSize
        leftButtonBlueNode.size = arrowButtonSize
        rightButtonBlueNode.size = arrowButtonSize
        
        upButtonBlueNode.zPosition = 55.0
        downButtonBlueNode.zPosition = 55.0
        leftButtonBlueNode.zPosition = 55.0
        rightButtonBlueNode.zPosition = 55.0
        
        upButtonBlueNode.name = upButtonBlueNodeName
        downButtonBlueNode.name = downButtonBlueNodeName
        leftButtonBlueNode.name = leftButtonBlueNodeName
        rightButtonBlueNode.name = rightButtonBlueNodeName

        
        upButtonBlueNode.position = CGPoint(x: playableRect.width/2 - (upButtonBlueNode.size.width + 125),
                                            y: arrowButtonSize.height * 3 - playableRect.height/2)
        // base position off of up button so if moved they all move together
        downButtonBlueNode.position = CGPoint(x: upButtonBlueNode.position.x, y: upButtonBlueNode.position.y - 2 * arrowButtonSize.height)
        leftButtonBlueNode.position = CGPoint(x: upButtonBlueNode.position.x - arrowButtonSize.width, y: upButtonBlueNode.position.y - arrowButtonSize.height)
        rightButtonBlueNode.position = CGPoint(x: upButtonBlueNode.position.x + arrowButtonSize.width, y: upButtonBlueNode.position.y - arrowButtonSize.height)
        
        downButtonBlueNode.zRotation = .pi
        leftButtonBlueNode.zRotation = .pi / 2
        rightButtonBlueNode.zRotation = 3 * .pi / 2
        
        cameraNode.addChild(upButtonBlueNode)
        cameraNode.addChild(downButtonBlueNode)
        cameraNode.addChild(leftButtonBlueNode)
        cameraNode.addChild(rightButtonBlueNode)
        
        
        // red buttons
        upButtonRedNode = SKSpriteNode(imageNamed: "arrowButtonRed")
        downButtonRedNode = SKSpriteNode(imageNamed: "arrowButtonRed")
        leftButtonRedNode = SKSpriteNode(imageNamed: "arrowButtonRed")
        rightButtonRedNode = SKSpriteNode(imageNamed: "arrowButtonRed")

        upButtonRedNode.size = arrowButtonSize
        downButtonRedNode.size = arrowButtonSize
        leftButtonRedNode.size = arrowButtonSize
        rightButtonRedNode.size = arrowButtonSize

        upButtonRedNode.zPosition = 55.0
        downButtonRedNode.zPosition = 55.0
        leftButtonRedNode.zPosition = 55.0
        rightButtonRedNode.zPosition = 55.0

        upButtonRedNode.name = upButtonRedNodeName
        downButtonRedNode.name = downButtonRedNodeName
        leftButtonRedNode.name = leftButtonRedNodeName
        rightButtonRedNode.name = rightButtonRedNodeName


        upButtonRedNode.position = CGPoint(x: -playableRect.width/2 + (upButtonRedNode.size.width + 125),
                                            y: arrowButtonSize.height * 3 - playableRect.height/2)
        // base position off of up button so if moved they all move together
        downButtonRedNode.position = CGPoint(x: upButtonRedNode.position.x, y: upButtonRedNode.position.y - 2 * arrowButtonSize.height)
        leftButtonRedNode.position = CGPoint(x: upButtonRedNode.position.x - arrowButtonSize.width, y: upButtonRedNode.position.y - arrowButtonSize.height)
        rightButtonRedNode.position = CGPoint(x: upButtonRedNode.position.x + arrowButtonSize.width, y: upButtonRedNode.position.y - arrowButtonSize.height)

        downButtonRedNode.zRotation = .pi
        leftButtonRedNode.zRotation = .pi / 2
        rightButtonRedNode.zRotation = 3 * .pi / 2

        cameraNode.addChild(upButtonRedNode)
        cameraNode.addChild(downButtonRedNode)
        cameraNode.addChild(leftButtonRedNode)
        cameraNode.addChild(rightButtonRedNode)

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
        resumeButton.setScale(0.7)
        resumeButton.position = CGPoint(x: -pausePanel.frame.width/2.0 + resumeButton.frame.width * 1.5, y: 0.0)
        pausePanel.addChild(resumeButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitFromPauseButtonNodeName
        quitButton.setScale(0.7)
        quitButton.position = CGPoint(x: pausePanel.frame.width/2.0 - quitButton.frame.width * 1.5, y: 0.0)
        pausePanel.addChild(quitButton)
        
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
        if collidedBlue && collidedRed {
            postGamePanelTitle.text = "Game Over: Draw Game"
        } else if collidedBlue {
            postGamePanelTitle.text = "Game Over: Red Wins!"
        } else if collidedRed {
            postGamePanelTitle.text = "Game Over: Blue Wins!"
        }
        postGamePanelTitle.fontSize = 70
        postGamePanelTitle.fontColor = SKColor.black
        postGamePanelTitle.position = CGPoint(x: postGamePanel.frame.midX, y: postGamePanel.frame.height/2.0 + 50)
        postGamePanel.addChild(postGamePanelTitle)
        
        let postGamePanelMessage = SKLabelNode(fontNamed: "rimouski sb")
//        postGamePanelMessage.text = "\(playerScore) - \(playerScore + 1)"
        postGamePanelMessage.fontSize = 60
        postGamePanelMessage.fontColor = SKColor.black
        postGamePanelMessage.position = CGPoint(x: postGamePanel.frame.midX, y: postGamePanel.frame.height/2.0 + 5)
        postGamePanel.addChild(postGamePanelMessage)
        
        let replayButton = SKSpriteNode(imageNamed: "resume")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(0.7)
        replayButton.position = CGPoint(x: -postGamePanel.frame.width/2.0 + replayButton.frame.width * 1.5, y:0.0)
        postGamePanel.addChild(replayButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitFromPostButtonNodeName
        quitButton.setScale(0.7)
        quitButton.position = CGPoint(x: postGamePanel.frame.width/2.0 - quitButton.frame.width * 1.5, y: 0.0)
        postGamePanel.addChild(quitButton)
        
        
    }
}


enum Direction {
    case up
    case down
    case left
    case right
}
