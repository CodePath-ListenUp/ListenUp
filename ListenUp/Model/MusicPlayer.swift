//
//  MusicPlayer.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/19/22.
//

import AVFoundation
import Foundation

// Source: https://stackoverflow.com/a/56488288

class MusicPlayer: NSObject, AVPlayerPlaybackCoordinatorDelegate {
    public static var instance = MusicPlayer()
//    var player = AVPlayer()
    var player = AVPlayer()
    var whenDone: () -> () = {}

    func initPlayer(url: String, whenDone: @escaping ()->()) {
        print(url)
        guard let url = URL(string: url) else {
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        self.whenDone = whenDone
        
        playAudioBackground()
    }
    
    
    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [/*.mixWithOthers, .allowAirPlay*/])
            print("Playback OK")
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func pause(){
        let _ = player.fadeVolume(from: 1.0, to: 0.0, duration: 0.5) {
            self.player.pause()
        }
    }
    
    func play() {
        let _ = player.fadeVolume(from: 0.0, to: 1.0, duration: 0.5) {
            self.player.play()
        }
    }
    
    @objc func playerDidFinishPlaying() {
        whenDone()
    }

}

extension AVPlayer {
    func fadeVolume(from: Float, to: Float, duration: Float, completion: (() -> Void)? = nil) -> Timer? {
        volume = from
        
        // Make sure there is a fade that must happen
        guard from != to else { return nil }
        
        // Define time interval the interaction will loop into
        let interval: Float = 0.1
        // this value is a fraction of a second
        
        // Set range the volume will move
        let range = to-from
        
        // Based on the range, the interval and duration, we calculate how big is the step we need to take in order to reach the target in the given duration
        let step = (range*interval)/duration
        
        func reachedTarget() -> Bool {
            // checks whether or not the volume has reached the min/max
            guard volume >= 0, volume <= 1 else {
                volume = to
                return true
            }
            
            // checks whether the volume is going forward or backward and compare current volume to target
            if to > from {
                return volume >= to
            }
            else {
                return volume <= to
            }
        }
        
        func willReachTarget() -> Bool {
            // checks whether or not the volume has reached the min/max
            guard volume >= 0, volume <= 1 else {
                volume = to
                return true
            }
            
            // checks whether the volume is going forward or backward and compare current volume to target
            if to > from {
                return volume + step >= to
            }
            else {
                return volume + step <= to
            }
        }
        
        // Create a timer that will repeat itself with the given interval
        return Timer.scheduledTimer(withTimeInterval: Double(interval), repeats: true) { [weak self] (timer) in
            // Check that we actually have a player to work with
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Check if we reached the target, otherwise we add the volume
                if !reachedTarget() {
                    // note that if the step is negative, meaning that the to value is lower than the from value, the volume will be decreased instead
                    if !willReachTarget() {
                        self.volume += step
                    }
                    else {
                        self.volume = to
                    }
                    print(self.volume, Double(self.volume))
                }
                else {
                    timer.invalidate()
                    completion?() // run the completion if we have one
                }
            }
        }
    }
}
