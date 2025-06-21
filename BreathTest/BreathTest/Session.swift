//
//  Session.swift
//  BreathTest
//
//  Created by John Kine on 2024-11-14.
//

import Foundation
import SwiftData


enum clockDisplayLabel: String, Codable {
    case breath
    case time
    case cycleDescription
}

enum CycleStages: String, Codable {
    case announceCycleNo
    case breaths
    case breathsRecovery
    case longHold
    case longHoldRecovery
    case shortHold
    case prepareNextCycle
}

struct Cycle: Codable,Hashable, Identifiable {
    var id: UUID = .init()
    var breaths = 20
    var inhale = 1.0
    var exhale = 1.0
    var breathHold = 10
    var finalHold = 10
   
    
}

struct SessionAudioInfo2: Codable,Hashable, Identifiable {
    var id: UUID = .init()
    var currentCycleStage: CycleStages = .announceCycleNo
    var upDateCount = true
    var displayText = ["","",""]
    var audioStr = [""]
    var extType = "wav"
    var duration = 0
    var interval: TimeInterval = 0.0
    var fadeAudio: Bool = false
    
    
}
// Future Changes
struct SessionPlayInfo: Codable,Hashable, Identifiable {
    var id: UUID = .init()
    var displayLabel: clockDisplayLabel = .breath
    //var clock = true
    //var playCadence = false
    var audioStr = ""
    var extType = "m4a"
    var duration = 0
    var interval: TimeInterval = 0.0
    var fadeAudio: Bool = false
    
}

@Model
class Session {
        
    var title: String
    var saved: Bool = false
    var playMeditaion = false
    var meditationTime = 0
    var meditaionTrack = "Default Track"
    var cycles = [Cycle]()

    init(title: String) {
        self.title = title
    }
    
 
    
}
