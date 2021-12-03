//
//  SKTAudio.swift
//  iosGameSuite
//
//  Created by Zach Fogg on 11/19/21.
//

import AVFoundation

class SKTAudio {
    var backgroundMusic: AVAudioPlayer?
    var soundEffect: AVAudioPlayer?
    
    static func sharedInstance() -> SKTAudio {
        return SKTAudioInstance
    }
    
    func playBackgroundMusic(_ fileNamed: String) {
        if !SKTAudio.musicEnabled { return }
        guard let url = Bundle.main.url(forResource: fileNamed, withExtension: nil) else { return }
        
        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            backgroundMusic = nil
        }
        
        if let backgroundMusic = backgroundMusic {
            backgroundMusic.numberOfLoops = -1
            backgroundMusic.prepareToPlay()
            backgroundMusic.play()
        }
    }
    
    func stopBackgroundMusic() {
        if let backgroundMusic = backgroundMusic {
            if !backgroundMusic.isPlaying {
                backgroundMusic.stop()
            }
        }
    }
    
    func pauseBackgroundMusic() {
        if let backgroundMusic = backgroundMusic {
            if !backgroundMusic.isPlaying {
                backgroundMusic.pause()
            }
        }
    }
    
    func resumeBackgroundMusic() {
        if let backgroundMusic = backgroundMusic {
            if !backgroundMusic.isPlaying {
                backgroundMusic.play()
            }
        }
    }
    
    func playSoundEffect(_ fileNamed: String) {
        guard let url = Bundle.main.url(forResource: fileNamed, withExtension: nil) else {return}
        
        do {
            soundEffect = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            soundEffect = nil
        }
        
        if let soundEffect = soundEffect {
            soundEffect.numberOfLoops = 0
            soundEffect.prepareToPlay()
            soundEffect.play()
        }
        
    }
    
    static let keyMusic = "keyMusic"
    static var musicEnabled: Bool = {
        return !UserDefaults.standard.bool(forKey: keyMusic)
    }() {
        didSet {
            let value = !musicEnabled
            UserDefaults.standard.set(value, forKey: keyMusic)
            
            if value {
                SKTAudio.sharedInstance().stopBackgroundMusic()
            }
        }
    }
}

private let SKTAudioInstance = SKTAudio()
