//
//  Helpers.swift
//  Side Scroller
//
//  Created by Robert Desjardins on 2018-05-08.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import Foundation
import AVFoundation

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

public extension SKSpriteNode {
    
    public func moveSprite(location: CGPoint, duration: CGFloat) {
        let actionMove = SKAction.move(to: location, duration: TimeInterval(duration))
        let actionMoveDone = SKAction.removeFromParent()
        self.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
}
