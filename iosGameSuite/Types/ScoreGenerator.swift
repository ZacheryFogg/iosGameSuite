//
//  ScoreGenerator.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/17/21.
//

import Foundation

//TODO: This should later be replaced with a "store", like with the individual project
class ScoreGenerator {
    static let sharedInstance = ScoreGenerator()
    
    private init() {}
    
    static let keyHighscore = "keyHighscore"
    static let keyScore = "keyScore"
    
    func setScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyScore)
    }
    
    func getScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }
    
    func setHighscore(_ highscore: Int) {
        UserDefaults.standard.set(highscore, forKey: ScoreGenerator.keyHighscore)
    }
    
    func getHighscore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyHighscore)
    }
}
