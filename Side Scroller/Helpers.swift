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


func gameOverSceneLoad(view: UIView) {
    let scene = GameOverScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func gameSceneLoad(view: UIView) {
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.presentScene(scene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
}

func resetGameData() {
    GameData.shared.playerScore = 0
    GameData.shared.creditsEarned = 0
}

func formatHighScores(arrayOfScores: [Int]) {
    GameData.shared.playerHighScore = quicksort(arrayOfScores)
    GameData.shared.playerHighScore = Array(GameData.shared.playerHighScore.prefix(5))
}

func quicksort<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { return a }
    
    let pivot = a[a.count/2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    
    return quicksort(greater) + equal + quicksort(less)
}

public extension SKSpriteNode {
    
    public func moveSprite(location: CGPoint, duration: CGFloat) {
        let actionMove = SKAction.move(to: location, duration: TimeInterval(duration))
        let actionMoveDone = SKAction.removeFromParent()
        self.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
}

public extension CGFloat {
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
}
