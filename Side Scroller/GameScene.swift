//
//  GameScene.swift
//  Side Scroller
//
//  Created by Robert Desjardins on 2018-05-02.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let worldNode = SKNode()
    
  
    private var touching = false
    
    private var lastUpdateTime : TimeInterval = 0
    private var timeUntilNextAttack : CGFloat = 0
    private var startGame: Bool = false
    private var firstTimeStart = true
    private var gameOver: Bool = false
    private var highScoreTable = SKLabelNode(fontNamed: "Avenir")
    private var highScoreBackground: SKSpriteNode! = nil
    private var startLabel: SKLabelNode! = nil
    private var scoreLabel = SKLabelNode(fontNamed: "Avenir")
    private var counter: Int = 0                                      // Used for score keeping
    
    // Background
    let background1 = SKSpriteNode(imageNamed: "glacial_mountains_lightened")
    let background2 = SKSpriteNode(imageNamed: "glacial_mountains_lightened")
    
    private var obstacle1Array : [Wall] = []
    private var obstacle2TopArray : [Wall] = []
    private var obstacle2BottomArray : [Wall] = []
    
    private var distanceBetweenObstacle1 : CGFloat = 3
    private var distanceBetweenObstacle2 : CGFloat = 3.5
    
    override func sceneDidLoad() {
        processGameData()
        addChild(worldNode)
        physicsWorld.contactDelegate = self
        setUpScreen()
        setupBackground()
        setUpHighScoreTable()
        setUpTouchScreenToStartLabel()
    }
    
    func processGameData() {
        GameData.shared.playerHighScore = UserDefaults.standard.getUserHighScores()
        GameData.shared.totalCredits = UserDefaults.standard.getUserCredits()
    }
    
    func setUpScreen() {
        
        scene?.scaleMode = SKSceneScaleMode.resizeFill
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        self.physicsBody?.contactTestBitMask = PhysicsCategory.None
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player
    }
    
    func setupBackground() {
        background1.anchorPoint = CGPoint(x: 0, y: 0)
        background1.position = CGPoint(x: 0, y: 0)
        background1.zPosition = -15
        background1.size.width = size.width
        background1.size.height = background1.size.width * 0.5625
        self.addChild(background1)
        
        background2.anchorPoint = CGPoint(x: 0, y: 0)
        background2.position = CGPoint(x: background1.size.width, y: 0)
        background2.zPosition = -15
        background2.size.width = size.width
        background2.size.height = background2.size.width * 0.5625
        self.addChild(background2)
    }
    
    func updateBackground() {
        background1.position = CGPoint(x: background1.position.x - 1, y: background1.position.y)
        background2.position = CGPoint(x: background2.position.x - 1, y: background2.position.y)
        
        if(background1.position.x < 0 - background1.size.width)
        {
            background1.position = CGPoint(x: background2.position.x + background2.size.width, y: background2.position.y)
        }
        
        if(background2.position.x < 0 - background2.size.width)
        {
            background2.position = CGPoint(x: background1.position.x + background2.size.width, y: background1.position.y)
        }
    }
    
    func setUpPlayer() {
        let player:Player = Player(color: UIColor.white, size: CGSize(width: GameData.shared.playerWidth, height: GameData.shared.playerHeight))
        player.initPlayer()
        player.position = CGPoint(x: size.width * (1/6), y: size.height * (1/2))
        worldNode.addChild(player)
    }
    
    func setUpHighScoreTable() {
        highScoreTable.fontSize = size.width / 48
        highScoreTable.zPosition = 5
        highScoreTable.fontColor = SKColor.white
        highScoreTable.numberOfLines = 6
        highScoreTable.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        highScoreTable.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        highScoreTable.text = "High Scores:\n"
        for highScore in GameData.shared.playerHighScore {
            highScoreTable.text?.append("\(highScore)\n")
        }
        
        addChild(highScoreTable)
        
        let scoreBGWidth = highScoreTable.frame.size.width + 40
        let scoreBGHeight = scoreBGWidth * 1.3042596349
        highScoreBackground = SKSpriteNode(imageNamed: "vertical-medium")
        highScoreBackground.zPosition = 2
        highScoreBackground.size = CGSize(width: scoreBGWidth, height: scoreBGHeight)
        highScoreBackground.position = CGPoint(x: size.width - highScoreBackground.size.width/2, y: size.height - highScoreBackground.size.height/2)
        addChild(highScoreBackground)
        
        highScoreTable.position = highScoreBackground.position
    }
    
    func setUpTouchScreenToStartLabel() {
        startLabel = SKLabelNode(fontNamed: "Avenir")
        startLabel.fontSize = 45
        startLabel.fontColor = SKColor.white
        startLabel.text = "Tap to Start"
        startLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        worldNode.addChild(startLabel)
    }
    
    func setUpHud() {
        scoreLabel.fontSize = 15
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = String("Score: \(GameData.shared.playerScore)")
        
        //TODO: Test this on iphoneX
        if UIScreen.main.nativeBounds.height == 2436.0 {
            scoreLabel.position = CGPoint(x: 0, y: size.height - (scoreLabel.frame.size.height + 22))
        } else {
            scoreLabel.position = CGPoint(x: 0, y: size.height - scoreLabel.frame.size.height)
        }
        
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
    }
    
    func updateHud(){
        scoreLabel.text = String("Score: \(GameData.shared.playerScore)")
    }
    
    
    func randomObstacle(obsticle: Int) {
        switch obsticle {
        case 1:
            obstacle1()
        case 2:
            obstacle2()
        default:
            print("Default Obstacle - shouldn't occur")
        }
    }
    
    func updateObstacles() {
        updateObstacle1()
        updateObstacle2()
    }
    
    // Two walls spawn with a fixed distance between them and move towards the left side of the screen
    func obstacle1() {
        timeUntilNextAttack = 1
        
        let topWall = Wall(color: UIColor.white, size: CGSize(width: 1, height: 1))
        topWall.initWall()
        topWall.position = CGPoint(x: size.width + topWall.size.width/2, y: random(min: topWall.size.height / 2 + GameData.shared.playerHeight * distanceBetweenObstacle1, max: size.height + topWall.size.height/2))
        worldNode.addChild(topWall)
        
        let bottomWall = Wall(color: UIColor.white, size: CGSize(width: 1, height: 1))
        bottomWall.initWall()
        bottomWall.position = topWall.position - CGPoint(x: 0, y: bottomWall.size.height + GameData.shared.playerHeight * distanceBetweenObstacle1)
        worldNode.addChild(bottomWall)
        obstacle1Array.append(topWall)
        obstacle1Array.append(bottomWall)
    }
    
    func updateObstacle1() {
        for wall in obstacle1Array {
            wall.position = wall.position - CGPoint(x: findSpeedBasedOnScreenSize(numberOfSeconds: 2), y: 0)
            if wall.position.x <= -wall.size.width {
                obstacle1Array.remove(at: obstacle1Array.index(of: wall)!)
                wall.removeFromParent()
            }
        }
    }
    
    // Walls move up and down, with a hole between both walls
    func obstacle2() {
        timeUntilNextAttack = 1
        
        let movingUpOrDown = CGFloat.randomSign
        
        
        let topWall = Wall(color: UIColor.white, size: CGSize(width: 1, height: 1))
        topWall.initWall()
        topWall.position = CGPoint(x: size.width + topWall.size.width/2, y: random(min: topWall.size.height / 2 + GameData.shared.playerHeight * distanceBetweenObstacle2, max: size.height + topWall.size.height/2))
        topWall.currentVelocity = movingUpOrDown
        worldNode.addChild(topWall)
        
        let bottomWall = Wall(color: UIColor.white, size: CGSize(width: 1, height: 1))
        bottomWall.initWall()
        bottomWall.position = topWall.position - CGPoint(x: 0, y: bottomWall.size.height + GameData.shared.playerHeight * distanceBetweenObstacle2)
        bottomWall.currentVelocity = movingUpOrDown
        worldNode.addChild(bottomWall)
        
        obstacle2TopArray.append(topWall)
        obstacle2BottomArray.append(bottomWall)
        
    }
    
    
    func updateObstacle2() {
        for wall in obstacle2TopArray {
            wall.position = wall.position - CGPoint(x: findSpeedBasedOnScreenSize(numberOfSeconds: 2), y: 0)
            if wall.currentVelocity > 0 && (wall.position.y >= size.height + wall.size.height/2){
                // Wall is moving beyond top bounds so change direction
                wall.currentVelocity = wall.currentVelocity * -1
            } else if wall.currentVelocity < 0 && (wall.position.y <= wall.size.height / 2 + GameData.shared.playerHeight * distanceBetweenObstacle2) {
                // Wall is moving beyond bottom bounds so change direction
                wall.currentVelocity = wall.currentVelocity * -1
            } else {
                wall.position = wall.position + CGPoint(x: 0, y: wall.currentVelocity)
            }
            if wall.position.x <= -wall.size.width {
                obstacle2TopArray.remove(at: obstacle2TopArray.index(of: wall)!)
                wall.removeFromParent()
            }
        }
        
        for wall in obstacle2BottomArray {
            wall.position = wall.position - CGPoint(x: findSpeedBasedOnScreenSize(numberOfSeconds: 2), y: 0)
            if wall.currentVelocity > 0 && (wall.position.y + wall.size.height/2 >= size.height - GameData.shared.playerHeight * distanceBetweenObstacle2){
                // Wall is moving beyond top bounds so change direction
                wall.currentVelocity = wall.currentVelocity * -1
            } else if wall.currentVelocity < 0 && (wall.position.y <= -wall.size.height/2) {
                // Wall is moving beyond bottom bounds so change direction
                wall.currentVelocity = wall.currentVelocity * -1
            } else {
                wall.position = wall.position + CGPoint(x: 0, y: wall.currentVelocity)
            }
            if wall.position.x <= -wall.size.width {
                obstacle2BottomArray.remove(at: obstacle2BottomArray.index(of: wall)!)
                wall.removeFromParent()
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        touching = true
        startGame = true
    }
    
    func touchUp(atPoint pos : CGPoint) {
        touching = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchDown(atPoint: touch.location(in: view))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchUp(atPoint: touch.location(in: view))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchUp(atPoint: touch.location(in: view))
        }
    }
    
    // Called when there is a collision between two nodes.
    func collisionBetween(ob1: SKNode, ob2: SKNode){
        if ob1.name == GameData.shared.kPlayerName && ob2.name == GameData.shared.kObstacleName {
            if !gameOver {
                gameOverSceneLoad(view: view!)
            }
            gameOver = true
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA.name == GameData.shared.kPlayerName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == GameData.shared.kPlayerName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if startGame && firstTimeStart {
            firstTimeStart = false
            startLabel.removeFromParent()
            highScoreTable.removeFromParent()
            highScoreBackground.removeFromParent()
            setUpHud()
            setUpPlayer()
        }
        
        if startGame {
            counter = counter + 1
            GameData.shared.playerScore = GameData.shared.playerScore + 1
            updateHud()
            updateBackground()
            updateObstacles()
        }
        
        if touching && startGame {
            if let player = worldNode.childNode(withName: GameData.shared.kPlayerName) as? SKSpriteNode {
                player.physicsBody?.applyForce(CGVector(dx: 0, dy: 200))
            }
        }
        
        // set lastUpdateTime to currentTime if it has not already been set
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // If enough time has passed, call a random obstacle
        if startGame && CGFloat(dt) >= timeUntilNextAttack {
            self.lastUpdateTime = currentTime
            randomObstacle(obsticle: Int(arc4random_uniform(2) + 1))
        }
    }
}
