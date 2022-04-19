//
//  MusicPlayer.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/19/22.
//

import AVFoundation
import Foundation

// Source: https://stackoverflow.com/a/56488288

class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    public static var instance = MusicPlayer()
    var player = AVPlayer()

    func initPlayer(url: String) {
        print(url)
        guard let url = URL(string: url) else {
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playAudioBackground()
    }
    
    
    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [/*.mixWithOthers, .allowAirPlay*/])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func pause(){
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("not yet implemented: didFinishPlaying")
    }
}
