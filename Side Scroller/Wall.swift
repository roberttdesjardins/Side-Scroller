//
//  Obstacle1.swift
//  Side Scroller
//
//  Created by Robert Desjardins on 2018-05-08.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Wall: SKSpriteNode {
    
    var currentVelocity:CGFloat =  1

    
    func initWall() {
        self.name = GameData.shared.kObstacleName
        self.size = CGSize(width: 30, height: GameData.shared.deviceHeight)
        self.zPosition = 2
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
}
