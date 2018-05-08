//
//  GameData.swift
//  Side Scroller
//
//  Created by Robert Desjardins on 2018-05-08.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class GameData {
    static let shared = GameData()
    var kPlayerName = "playerName"
    var kObstacleName = "obstacleName"
    var deviceWidth = UIScreen.main.bounds.size.width
    var deviceHeight = UIScreen.main.bounds.size.height
    
    var playerHeight : CGFloat = 40
    var playerWidth : CGFloat = 40
    
    var playerScore = 0
    var playerHighScore: [Int] = []
    var creditsEarned: Int = 0
    var totalCredits: Int = 0
    
    private init() { }
}
