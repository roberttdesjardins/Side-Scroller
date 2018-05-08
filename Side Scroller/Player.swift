//
//  Player.swift
//  Side Scroller
//
//  Created by Robert Desjardins on 2018-05-02.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation
class Player: SKSpriteNode {
    
    func initPlayer() {
        self.size = CGSize(width: GameData.shared.playerWidth, height: GameData.shared.playerHeight)
        self.zPosition = 6
        self.name = GameData.shared.kPlayerName
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Edge
        self.physicsBody?.collisionBitMask = PhysicsCategory.Edge
    }
}
