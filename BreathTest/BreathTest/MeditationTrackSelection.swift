//
//  MeditationTractSelection.swift
//  BreathTest
//
//  Created by John Kine on 2024-11-19.
//

import SwiftUI
import AVKit


//class SessionSettings: ObservableObject {
//    @Published var meditationTrack = ""
//}

struct MeditationTrackSelection: View {
    
    @State private var selection: String?
    
    @EnvironmentObject var trackSelected: SessionSettings
    
    @Environment(\.dismiss) var dismiss
    
    @State private var player: AVAudioPlayer?
    @State private var isplaying = false
    @State private var buttonStr: String = "Play"
    //let session: Session
    
    
     let names = [
         "Mono",
         "Designed",
         "Pages",
         "Euphorbia",
         "Night Winds",
         "Calm World",
         "Deep And Hollow",
         "Atmosphere",
         "Noctis",
         "Limitless"
     ]

     var body: some View {
         NavigationStack {
             List(names, id: \.self, selection: $selection) { name in
                 Text(name)
             }
             .toolbar {
                 if let _ = selection {
                     
                     Button("Done") {
                         trackSelected.meditationTrack = selection ?? "Default Track"
                         dismiss()
                     }
                     .buttonStyle(.borderedProminent)
                     .monospaced()
                     Button(buttonStr) {
                         if buttonStr == "Play" {
                             buttonStr = "Stop"
                             playSound(named: "MeditationLong") // Call function to play the click sound
                         } else {                             
                             player?.stop()
                             buttonStr = "Play"
                             }
                     }
                     .monospaced()
                     .buttonStyle(.borderedProminent)
                 }
                 Button("Cancel") {
                     dismiss()
                 }
                 .buttonStyle(.borderedProminent)
                 .disabled(selection != nil)

             }
             .navigationTitle("Track Selection")
             VStack {
                 Text("Selected Track: \(self.selection ?? "None")")
             }
         }
     }
  
    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "m4a") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Error loading audio: \(error)")
        }
        
        player?.play()
    }
    
    
    
}


#Preview {
    MeditationTrackSelection()
}
