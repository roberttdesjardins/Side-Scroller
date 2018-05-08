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
    private var counter: Int = 0
    
    override func sceneDidLoad() {
        addChild(worldNode)
        physicsWorld.contactDelegate = self
        setUpBackground()
        setUpPlayer()
        
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
    
    
    override func update(_ currentTime: TimeInterval) {
        if touching {
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
        if CGFloat(dt) >= timeUntilNextAttack {
            self.lastUpdateTime = currentTime
            randomObstacle(obsticle: Int(arc4random_uniform(1) + 1))
        }
    }
}
