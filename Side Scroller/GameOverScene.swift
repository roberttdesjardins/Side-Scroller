//
//  GameOverScene.swift
//  Side Scroller
//
//  Created by Robert Desjardins on 2018-05-10.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

// TODO: If score is above a certain point, different sound effect - No one has ever done that, noice, ...wow etc.

class GameOverScene: SKScene {
    
    var restartButton: SKSpriteNode! = nil
    var losingSound: AVAudioPlayer! = nil
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        createRestartButton()
        GameData.shared.creditsEarned = GameData.shared.creditsEarned + Int(round(Double(GameData.shared.playerScore/35)))
        createScoreLabel()
        GameData.shared.playerHighScore.append(GameData.shared.playerScore)
        formatHighScores(arrayOfScores: GameData.shared.playerHighScore)
        UserDefaults.standard.setUserHighScores(array: GameData.shared.playerHighScore)
        let newCreditBalance = GameData.shared.totalCredits + GameData.shared.creditsEarned
        UserDefaults.standard.setUserCredits(credits: newCreditBalance)
        resetGameData()
    }
    
    func createRestartButton() {
        let buttonWidth = size.width - 80
        let buttonHeight = buttonWidth * 0.2974683544
        restartButton = SKSpriteNode(imageNamed: "button_restart")
        restartButton.zPosition = 2
        restartButton.size = CGSize(width: buttonWidth, height: buttonHeight)
        restartButton.position = CGPoint(x: size.width/2, y: restartButton.size.height + 10)
        addChild(restartButton)
    }
    
    func createScoreLabel() {
        let scoreLabel = SKLabelNode(fontNamed: "Avenir")
        scoreLabel.fontSize = 35
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = "Score: \(GameData.shared.playerScore)"
        scoreLabel.position = restartButton.position - CGPoint(x: 0, y: (restartButton.size.height/2 + 35))
        
        self.addChild(scoreLabel)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if restartButton.contains(touchLocation) {
            gameSceneLoad(view: view!)
        }
    }
}
