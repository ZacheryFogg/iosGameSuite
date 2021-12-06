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
    let startingSize = 3
    let maxPellets = 3
    var snakeBlue: [SKSpriteNode] = []
    var snakeRed: [SKSpriteNode] = []
    
    var collidedBlue = false
    var collidedRed = false
    
    var directionBlue = Direction.left
    var directionRed = Direction.right
    
    var pointPellets: [SKSpriteNode] = []
    
    //MARK: - Properties
    
    // controls snake speed number represents seconds/block
    let refreshRate = 0.3
    
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
    let quitButtonNodeName: String = "quitButtonNode"
    let replayButtonNodeName: String = "replayButtonNode"
    
    let upButtonBlueNodeName: String = "upButtonBlueNode"
    let downButtonBlueNodeName: String = "downButtonBlueNode"
    let leftButtonBlueNodeName: String = "leftButtonBlueNode"
    let rightButtonBlueNodeName: String = "rightButtonBlueNode"
    
    let upButtonRedNodeName: String = "upButtonRedNode"
    let downButtonRedNodeName: String = "downButtonRedNode"
    let leftButtonRedNodeName: String = "leftButtonRedNode"
    let rightButtonRedNodeName: String = "rightButtonRedNode"
    
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
    
    
    // calculate grid area based on playable area and snake size
    var maxHeight: Int {
        var height = 0
        while playableRect.height/2 + snakeSize.height * CGFloat(height + 1) < playableRect.height {
            height += 1
        }
        return height
    }
    var minHeight: Int {
        var height = 0
        while playableRect.height/2 + snakeSize.height * CGFloat(height - 1) > 0 {
            height -= 1
        }
        return height
    }
    var maxWidth: Int {
        var width = 0
        while playableRect.width/2 + snakeSize.width * CGFloat(width + 1) < playableRect.width {
            width += 1
        }
        return width
    }
    var minWidth: Int {
        var width = 0
        while playableRect.width/2 + snakeSize.width * CGFloat(width - 1) > 0 {
            width -= 1
        }
        return width
    }
    
    //MARK: - Systems
    override func didMove(to view: SKView) {
        self.setupNodes()
    }
    
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
            
            let menuScene: SKScene = MenuScene(size: CGSize(width: self.size.width / 3, height: self.size.height / 3))
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
        
        } else if node.name == quitButtonNodeName {
            let menuScene: SKScene = MenuScene(size: CGSize(width: self.size.width / 3, height: self.size.height / 3))
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
            checkPelletEaten()
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
        
        createPauseButton()
        
        createCamera()
        
        createPointPellets()
    }
    
    func createBackground(){
        let background = SKSpriteNode(imageNamed: "snakeBackground")
        background.name = "Background"
        background.position = CGPoint(x: 0, y: 0) //self.size.width/2, y: self.size.height/2)
        background.size = CGSize(width: playableRect.width, height: playableRect.height)
        background.zPosition = -1.0 // Make sure is appears behind other children
        cameraNode.addChild(background)
    }

    
    func createSnakes(){

        for i in 0..<startingSize {
            let snakeBody = SKSpriteNode(imageNamed: "snakeBodyBlue")
            snakeBody.name = "SnakeBodyBlue"
            snakeBody.position = CGPoint(x: (7 + CGFloat(i)) * snakeSize.width, y: 0)
            snakeBody.size = snakeSize
            snakeBody.zPosition = 45.0
            cameraNode.addChild(snakeBody)
            snakeBlue.append(snakeBody)
        }
        
        for i in 0..<startingSize {
            let snakeBody = SKSpriteNode(imageNamed: "snakeBodyRed")
            snakeBody.name = "SnakeBodyRed"
            snakeBody.position = CGPoint(x:  -(7 + CGFloat(i)) * snakeSize.width, y: 0)
            snakeBody.size = snakeSize
            snakeBody.zPosition = 45.0
            cameraNode.addChild(snakeBody)
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
            pointPellet.position = CGPoint(x: playableRect.width/2, y: playableRect.height/2)
            pointPellet.size = pelletSize
            pointPellet.zPosition = 56.0
            cameraNode.addChild(pointPellet)
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
        
        // check out of bounds
        if (snakeBlue[0].position.y < CGFloat(minHeight) * snakeSize.height || snakeBlue[0].position.y > CGFloat(maxHeight) * snakeSize.height ||
            snakeBlue[0].position.x < CGFloat(minWidth) * snakeSize.width || snakeBlue[0].position.x > CGFloat(maxWidth) * snakeSize.width) {
            collidedBlue = true
        }
        if (snakeRed[0].position.y < CGFloat(minHeight) * snakeSize.height || snakeRed[0].position.y > CGFloat(maxHeight) * snakeSize.height ||
            snakeRed[0].position.x < CGFloat(minWidth) * snakeSize.width || snakeRed[0].position.x > CGFloat(maxWidth) * snakeSize.width) {
            collidedRed = true
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
    
    func checkPelletEaten() {
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
        
        print("minH: \(minHeight), maxH: \(maxHeight), minW: \(minWidth), maxW: \(maxWidth)")
        while locationInvalid {
            locationInvalid = false
            // put in playable rect
            pellet.position = CGPoint(x: snakeSize.width * CGFloat(Int.random(in: minWidth...maxWidth)), y: snakeSize.height * CGFloat(Int.random(in: minHeight...maxHeight)))
            
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
            
            if pellet.intersects(pauseButtonNode) {
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
            snakeBody.position = lastNodePos
            snakeBody.size = snakeSize
            snakeBody.zPosition = 45.0 // Above pause button but under controls
            cameraNode.addChild(snakeBody)
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
        cameraNode.position = CGPoint(x: playableRect.width/2, y: playableRect.height/2)//frame.midY)
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
    

    func createPauseButton(){
        pauseButtonNode = SKSpriteNode(imageNamed: "pause")
        pauseButtonNode.setScale(0.08 * 3)
        pauseButtonNode.zPosition = 50.0
        pauseButtonNode.name = pauseButtonNodeName
        pauseButtonNode.position = CGPoint(x: 0.0 + pauseButtonNode.frame.width/2 + 10.0, y: self.frame.maxY - pauseButtonNode.frame.height/2 - 10.0)
        self.addChild(pauseButtonNode)
    }
    
    func createPausePanel(){
        let menuScale = 0.08 * 3
        
        pauseContainerNode.position  = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2.0)
        self.addChild(pauseContainerNode)
        
        let pauseGamePanel = SKSpriteNode(imageNamed: "panel")
        pauseGamePanel.size = CGSize(width: self.frame.width/2.0, height: self.frame.width/4.0)
        pauseGamePanel.zPosition = 60.0
        pauseContainerNode.addChild(pauseGamePanel)
        
        let pauseGamePanelTitle = SKLabelNode(fontNamed: "")
        pauseGamePanelTitle.text = "Game Paused"
        pauseGamePanelTitle.zPosition = 80.0
        pauseGamePanelTitle.fontSize = 30 * 3
        pauseGamePanelTitle.fontColor = SKColor.white
    
        pauseGamePanelTitle.position = CGPoint(x: pauseGamePanel.frame.midX, y: pauseGamePanel.frame.maxY - 45.0 * 3)
        pauseGamePanel.addChild(pauseGamePanelTitle)
        

        let replayButton = SKSpriteNode(imageNamed: "replay")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(menuScale)
        replayButton.position = CGPoint(x: pauseGamePanel.frame.midX - (replayButton.frame.width * 1.4), y:pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(replayButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitButtonNodeName
        quitButton.setScale(menuScale)
        quitButton.position = CGPoint(x: pauseGamePanel.frame.midX + (quitButton.frame.width * 1.4) , y: pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(quitButton)
        
        let resumeButton = SKSpriteNode(imageNamed: "resume")
        resumeButton.zPosition = 70.0
        resumeButton.name = resumeButtonNodeName
        resumeButton.setScale(menuScale * 1.5)
        resumeButton.position = CGPoint(x: pauseGamePanel.frame.midX , y: pauseGamePanel.frame.midY - 20.0)
        pauseGamePanel.addChild(resumeButton)
    }
    
    func createPostGamePanel(){
        let menuScale = 0.2 * 3
        
        postGameContainerNode.position  = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2.0)
        self.addChild(postGameContainerNode)
        
        let postGamePanel = SKSpriteNode(imageNamed: "panel")
        postGamePanel.size = CGSize(width: self.frame.width/1.8, height: self.frame.width/4.0)
        postGamePanel.zPosition = 60.0
        postGameContainerNode.addChild(postGamePanel)
        
        let postGamePanelTitle = SKLabelNode(fontNamed: "AmericanTypewriter")

        if collidedBlue && collidedRed {
            postGamePanelTitle.text = "Game Over: Draw"
        } else if collidedBlue {
            postGamePanelTitle.text = "Game Over: Red Wins!"
        } else if collidedRed {
            postGamePanelTitle.text = "Game Over: Blue Wins!"
        }
        postGamePanelTitle.zPosition = 80.0
        postGamePanelTitle.fontSize = 30 * 3
        postGamePanelTitle.fontColor = SKColor.white
    
        postGamePanelTitle.position = CGPoint(x: postGamePanel.frame.midX, y: postGamePanel.frame.maxY - 45.0 * 3)
        postGamePanel.addChild(postGamePanelTitle)
        

        let replayButton = SKSpriteNode(imageNamed: "replay")
        replayButton.zPosition = 70.0
        replayButton.name = replayButtonNodeName
        replayButton.setScale(menuScale * 0.56)
        replayButton.position = CGPoint(x: postGamePanel.frame.midX - replayButton.frame.width, y:postGamePanel.frame.midY - 20.0)
        postGamePanel.addChild(replayButton)
        
        let quitButton = SKSpriteNode(imageNamed: "back")
        quitButton.zPosition = 70.0
        quitButton.name = quitButtonNodeName
        quitButton.setScale(menuScale * 0.56)
        quitButton.position = CGPoint(x: postGamePanel.frame.midX + quitButton.frame.width , y: postGamePanel.frame.midY - 20.0)
        postGamePanel.addChild(quitButton)
    }
}


enum Direction {
    case up
    case down
    case left
    case right
}
