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
    private var counter: Int = 0                     // Used for score
    
    override func sceneDidLoad() {
        
        addChild(worldNode)
        physicsWorld.contactDelegate = self
        setUpBackground()
        setUpPlayer()
        setUpHighScoreTable()
        setUpTouchScreenToStartLabel()
    }
    
    func setUpBackground() {
        scene?.scaleMode = SKSceneScaleMode.resizeFill
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        self.physicsBody?.contactTestBitMask = PhysicsCategory.None
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player
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
        startLabel.text = "Touch To Start. Don't let go!"
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
        default:
            print("Default Obstacle - shouldn't occur")
        }
    }
    
    func obstacle1() {
        timeUntilNextAttack = 1
        
        let topWall = Wall(color: UIColor.white, size: CGSize(width: 1, height: 1))
        topWall.initWall()
        topWall.position = CGPoint(x: size.width + topWall.size.width/2, y: random(min: topWall.size.height / 2 + GameData.shared.playerHeight * 3, max: size.height + topWall.size.height/2))
        worldNode.addChild(topWall)
        
        let bottomWall = Wall(color: UIColor.red, size: CGSize(width: 1, height: 1))
        bottomWall.initWall()
        bottomWall.position = topWall.position - CGPoint(x: 0, y: bottomWall.size.height + GameData.shared.playerHeight * 3)
        worldNode.addChild(bottomWall)
        
        print("bottomWall height = \(bottomWall.size.height)")
        
        topWall.moveSprite(location: topWall.position - CGPoint(x: size.width + topWall.size.width, y: 0), duration: 2)
        
        bottomWall.moveSprite(location: bottomWall.position - CGPoint(x: size.width + bottomWall.size.width, y: 0), duration: 2)
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
            randomObstacle(obsticle: Int(arc4random_uniform(10) + 1))
        }
        
        if startGame {
            counter = counter + 1
            GameData.shared.playerScore = GameData.shared.playerScore + 1
            updateHud()
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
            randomObstacle(obsticle: Int(arc4random_uniform(1) + 1))
        }
    }
}
