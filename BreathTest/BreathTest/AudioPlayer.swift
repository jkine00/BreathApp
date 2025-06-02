//
//  AudioPlayer.swift
//  BreathTest
//
//  Created by John Kine on 2025-02-05.
//

import Foundation
import SwiftUI
import AVFoundation

// AudioPlayer class to handle audio playback logic
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var fadeTimer: Timer?
    private var playRepeats: Int = 0
    private var breathPlayListIndex = 0
    private var totalBreaths = 0
    private var soundRepeats:[Int] = []
    private var currentSoundRepeatCount:Int = 0
    private var breathRoutineTask: Task<Void, Never>?
    @Published var isPlaying = false
    @Published var isCycleComplete: Bool = true

    let inhaleDuration: TimeInterval = 1.0
    let tockDuration: TimeInterval = 1.0
    let bellDuration: TimeInterval = 1.0
    let exhaleDuration: TimeInterval = 1.0
    let recoverBreathDuration: TimeInterval = 7.0
    

    
    func playOther(otherAudio: SessionPlayInfo){
        playAudio(fileName: otherAudio.audioStr, fileExtension: "m4a", playForDuration:TimeInterval(otherAudio.duration), fade: otherAudio.fadeAudio, repeats: 0)
    }
    
    // Plays the audio file for the specified duration or until it's complete
    func playAudio(fileName: String, fileExtension: String, playForDuration duration: TimeInterval? = nil,fade: Bool? = nil, repeats: Int = 0) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Audio file not found!")
            return
        }
        
        do {
            playRepeats = repeats
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            print("File:\(fileName) Duration:\(audioPlayer?.duration ?? 0)")
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = repeats // Set number of repeats
            
            
            //print("length: \(audioPlayer?.duration ?? 0)")
            
            // Play the audio
            audioPlayer?.play()
            isCycleComplete = false
            isPlaying = true
            
            
            // If duration is specified, stop after the duration
            if let duration = duration {

                if fade != nil {
                    fadeTimer = Timer.scheduledTimer(withTimeInterval: duration - 10, repeats: false) { [weak self] _ in
                        self?.audioPlayer?.setVolume(0, fadeDuration: 10)
                    }
                } else {
                // Schedule a timer to stop audio after the specified time
                    timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                        //print("Inside timer duration:\(duration)")
                        if self?.totalBreaths == 0 {
                            self?.stopAudio()
                            self?.audioPlayer = nil
                        }  else {
                            self?.stopAudio()
                            self?.audioPlayer = nil
                        }
                    }
                }
            }
            
            // If no duration is provided, play the entire file
            else if duration == nil {
            // You can use audioPlayer?.duration to get the length of the file if needed.
            }
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    // Stops the audio playback
    func stopAudio() {
        //playAudio(fileName: "outBreath", fileExtension: "m4a")
        
        breathRoutineTask?.cancel()
        breathRoutineTask = nil
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        timer?.invalidate()
                
        if fadeTimer != nil {
            fadeTimer?.invalidate()
            
        }
    }
    
    // Toggle playback (pause or resume)
    func togglePlayback() {
        
        //print(isPlaying)
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                    
            } else {
                audioPlayer.play()
            }
            isPlaying.toggle()
        }
    }
    //Play breaths
    func startBreathRoutine(breaths: Int, inhaleBeats: Int, exhaleBeats: Int,inhaleDuration:TimeInterval, exhaleDuration: TimeInterval) {
        
        breathRoutineTask = Task {
            do {
                let start = CFAbsoluteTimeGetCurrent()
                for _ in 1...breaths {
                    
                    //let start = CFAbsoluteTimeGetCurrent()
                    
                    try Task.checkCancellation()
                    await PlayBreathAudio(named: "Inhale2", duration: 1.0)
        
                    try Task.checkCancellation()
                    await runBreathCadence(k: inhaleBeats)

                    try Task.checkCancellation()
                    await PlayBreathAudio(named: "Exhale2", duration: 1.0)
                    
                    try Task.checkCancellation()
                    await runBreathCadence(k: exhaleBeats)

                }
                
                let scheduledDuration = TimeInterval(breaths) * (inhaleDuration + exhaleDuration)
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                print("elaspsed time: \(elapsed) scheduled: \(scheduledDuration)")
                if elapsed < scheduledDuration {
                    await delay(seconds: scheduledDuration - elapsed)
                }
                                
            } catch {
                print("Breath routine was cancelled or encountered an error.")
            }
        }
    }
    
    func runFinalHoldCadence(k: Int) {
        breathRoutineTask = Task {
            do {
                try Task.checkCancellation()
                await delay(seconds: 1.0)
                await runBreathCadence(k: k)
                
            } catch {
                print("Cadence routine was cancelled or encountered an error.")
            }
        }
    }

    
    func runBreathCadence(k: Int) async {
        if k <= 0 { return }
        
        for j in 1...k {
            try? Task.checkCancellation()
            
            if k == 1 {
                await delay(seconds: 1.0)
                return 
            }
            
            if k == 2 {
                await PlayBreathAudio(named: "Bell2", duration: 2.0)
                return
            }
            if k > 2 {
                if j < k {
                    await PlayBreathAudio(named: "Tock2", duration: 1.0)
                } else if j == k {
                    await PlayBreathAudio(named: "Bell2", duration: 1.0)
                }
            }
        }

    }

        private func delay(seconds: TimeInterval) async {
            
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }

    private func PlayBreathAudio(named name: String, duration: TimeInterval) async {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a") else {
            print("Error: Audio file \(name).m4a not found.")
            return
        }
        
        do {
            let start = CFAbsoluteTimeGetCurrent()
            
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player
            
            
            player.prepareToPlay()
            player.play()
            
            // Wait until the audio finishes
            await delay(seconds: player.duration)
            
            player.stop()
            audioPlayer = nil

            // Add silence for the rest of the expected time
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            let remaining = duration - elapsed
            
            if remaining > 0 {
                await delay(seconds: remaining * 0.94)
            }
            
        } catch {
            print("Error playing audio \(name): \(error.localizedDescription)")
        }
    }

    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

    }

}






 

