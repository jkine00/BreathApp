
//
//  Breathe.swift
//  BreathTest
//
//  Created by John Kine on 2024-12-04.
//

import SwiftUI
import SwiftData
import AVFAudio

struct BreatheView: View {
        
    @StateObject private var player = AudioPlayer()
 
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Environment(\.modelContext) private var context
    
    @Environment(\.presentationMode) var presentationMode
    @State var showingRegistrationAlert = false
    @State var disableBtnFor1Sec: Bool = false
    
    @Query(sort:\Session.title) private var sessions: [Session]
    @State private var selectedSession: Session? = Session(title: "")
    @State private var totalCycles: Int = 0
    @State var count = 0
    @State var total = 0
    @State var currentCycle:Cycle?
    @State var isPlaying: Bool = false
    @State var breathComplete : Bool = false
    
    @State private var totalCycleTime: Double = 0
    @State private var totalTimeStr: String = ""
  
    @State private var currentIndex: Int = 0
    @State private var playIndex: Int = 0
    @State private var cycleTimer: Timer? = nil
    @State private var sessionTimer: Timer? = nil
    @State private var breathLabel = true
    @State private var playSessionValues = [SessionPlayInfo]()
    @State private var countdownValues = [Int]()
    @State private var showAlert: Bool = false
    @Binding var tabSelection: Int
    
    let charFont:Font = .system(size: UIScreen.main.bounds.width * 0.05)
    let charFont2:Font = .system(size: UIScreen.main.bounds.width * 0.04)
    let numberFont:Font = .system(size: UIScreen.main.bounds.width * 0.05,design:.monospaced)
    let titleLengthFactor = UIScreen.main.bounds.width < 400 ? 1.0 : 0.85
    
    let voice = AVSpeechSynthesizer()
    var progress: Double {
    
        
       return Double(total - count) / Double(total)
       
    }
    
    var body: some View {
        VStack {
            Form {
                Picker("Session:", selection: $selectedSession) {
                    ForEach(sessions) { session in
                        if selectedSession != nil {
                            Text(session.title).tag(session as Session?)
                            
                        }
                    }
                }
                
                .listRowInsets(.init(top: 0, leading: 5, bottom: 0, trailing: 5))
                .animation(Animation.linear(duration: 0.5))
                .disabled(isPlaying)
                .pickerStyle(.menu)
                .onChange(of: selectedSession) { oldValue, newValue in
        
                    if let newValue {
                        sessionSetSelected(selectedSession: newValue)
                        if let session = selectedSession {
                            count = session.cycles[0].breaths
                            total = 0
                        }
                    }
                }
            }
            
            .containerRelativeFrame(.horizontal) { length,_ in
                length * titleLengthFactor
                
            }
            .padding(.top,0)
            .scrollContentBackground(.hidden)
            .frame(height: 80)
           
            CircularProgressView(count: count, total: total, progress: progress, breathLabel: breathLabel)
               .padding(.top,10)
               .padding(.bottom,10)
        
            Divider()
            HStack {
                
                Button {
                   // print("Play Button Pressed: \(isPlaying)")
                    guard !disableBtnFor1Sec else { return }

                    disableBtnFor1Sec = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        disableBtnFor1Sec = false
                    }
                   
                        if !isPlaying {
                            isPlaying.toggle()
                            player.stopAudio()
                            selectedSession = sessions.first
                            
                            currentCycleCount = 1
                            startSession()
                        } else {
                            selectedSession = nil
                            player.stopAudio()
                            isPlaying.toggle()
                            cycleTimer?.invalidate()
                            cycleTimer = nil
                            sessionTimer?.invalidate()
                            sessionTimer = nil
                            totalCycleTime = 0
                            total = 0
                            currentIndex = 0
                            count = playSessionValues[currentIndex].duration
                            total = playSessionValues[currentIndex].duration
                            if let session = selectedSession {
                                totalCycleTime = setTotalSessionTime(selectedSession: session)
                                totalTimeStr = formatTime(time: totalCycleTime)
                            }
                            breathLabel = true
                            
                        }
                    
                    
                } label: {
                    switch isPlaying {
                    case true: Image(systemName: "pause.fill")
                    case false: Image(systemName: "play.fill")
                        
                    }
                }
                
                .disabled(disableBtnFor1Sec) // this greys it out and prevents taps
                .foregroundStyle(.blue)
                .font(.system(size: 38))
                
                
            }
            .padding(.top,5)
            .padding(.bottom,5)
            Divider()
            
            VStack {
                HStack {
                    Text("Session Remaining")
                        .font(charFont)
                        .foregroundColor(.secondary)
                        .padding(.leading,10)
                        .padding(.trailing,10)
                        .padding(.top)
                }
                Divider()
                    .overlay(isDarkMode ? Color.white : Color.black)
                
                HStack {
                                    
                    Text("Cycles:")
                        .font(charFont)
                        .foregroundColor(.secondary)
                        .padding(.leading,10)
                    Spacer()
                    Text("\(isPlaying ? ((totalCycles - currentIndex/4) - 1 > 0 ? (totalCycles - currentIndex/4) - 1: 0): totalCycles)")
                        .font(numberFont)
                        .foregroundColor(.secondary)
                        .padding(.trailing,10)
                }
                HStack {
                                        
                    Text("Time:")
                        .font(charFont)
                        .foregroundColor(.secondary)
                        .padding(.leading,10)
                        .padding(.bottom,10)
                    Spacer()
                    Text(totalTimeStr)
                        .font(numberFont)
                        .foregroundColor(.secondary)
                        .padding(.trailing,10)
                        .padding(.bottom,10)
                }
                
            }
            .containerRelativeFrame(.horizontal) { length,_ in
                length * 0.85
            }
            .addBorder(Color.secondary, width: 1, cornerRadius: 10)
            .padding(.top,5)
            Spacer()
        }
        .padding(.top,5)
        .toolbar(.hidden,for: isPlaying ? .tabBar : .automatic)
        .alert("Sessions must contain at least one sesssion, return to 'Settings' to add Your first Session", isPresented: $showAlert, actions: {
            Button("OK") {
                tabSelection = 0
            }
        })
        
        .onAppear {
                       
                if sessions.isEmpty {
                    showAlert = true
                }

            UIApplication.shared.isIdleTimerDisabled = true
            
            if sessions.count == 1 {
                sessions[0].saved = true
            }
            for session in sessions {
                if session.saved {
                    self.selectedSession = session
                    totalCycleTime = setTotalSessionTime(selectedSession: session)
                    totalCycles = session.cycles.count
                    countdownValues.removeAll()
                    if session.cycles.count > 0 {
                        if let session = selectedSession {
                            count = session.cycles[0].breaths
                            setCycleData(selectedSession: session)
                        }
                    }
                }
            }
        }
               
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func announceCurentCycle(currentCycle:Int, lastCycle:Int) {
        isPlaying = true
        var utterance = AVSpeechUtterance()
        if currentCycle < lastCycle {
            utterance = AVSpeechUtterance(string:"Cycle number \(currentCycle)")
        } else {
            utterance = AVSpeechUtterance(string:"Last Cycle")
        }
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        voice.speak(utterance)
    }
    
    @State var currentCycleCount = 1
    
    func startSession() {
        
        Task {
            if let currentSession = selectedSession {
                let totalSessionCycles = currentSession.cycles.count
                
                var timeInterval: TimeInterval = 1
                //totalCycleTime = setTotalSessionTime(selectedSession: currentSession)
                
                if currentIndex < playSessionValues.count {
                   
                    if currentCycleCount == currentIndex / 4 + 1 && currentIndex + 1 <= totalSessionCycles * 4 {
                        //announceCurentCycle(currentCycle: currentCycleCount, lastCycle: totalSessionCycles)
                        player.playAudio(fileName: "cycle#1", fileExtension: "wav",playForDuration: 2.0)
                        currentCycleCount += 1
                        await delay(seconds: 2.0)
                    }
                                        
                    count = playSessionValues[currentIndex].duration
                    total = playSessionValues[currentIndex].duration
                    
                    print("currentIndex: \(currentIndex)")
                    if playSessionValues[currentIndex].displayLabel == .breath {
                        
                        timeInterval = currentSession.cycles[currentIndex / 4].inhale + currentSession.cycles[currentIndex / 4].exhale
                         count  -= 1
                        let inBreathBeats = Int(currentSession.cycles[currentIndex / 4].inhale) - 1
                        let outBreathBeats = Int(currentSession.cycles[currentIndex / 4].exhale) - 1
                        player.startBreathRoutine(breaths: currentSession.cycles[currentIndex / 4].breaths,
                                                  inhaleBeats: inBreathBeats, exhaleBeats: outBreathBeats,
                                                  inhaleDuration: currentSession.cycles[currentIndex / 4].inhale,
                                                  exhaleDuration: currentSession.cycles[currentIndex / 4].exhale)
                        breathLabel = true
                        
                    } else {
                                                
                        breathLabel = false
                        timeInterval = 1
                        
                        switch playSessionValues[currentIndex].audioStr {

                        case "meditation" :
                            player.playAudio(fileName: "breathHoldPrep", fileExtension: "m4a")
                            await delay(seconds: 7.0)
                            player.playAudio(fileName: "meditation", fileExtension: "m4a",playForDuration: TimeInterval(currentSession.cycles[currentIndex / 4].breathHold),fade: true)
                        case "recoveryBreath" :
                            player.playAudio(fileName: "recoveryBreath", fileExtension: "m4a")
                            await delay(seconds: 8.0)
                            player.runFinalHoldCadence(k: currentSession.cycles[currentIndex / 4].finalHold)
                        case "sectionEnd":
                            player.playAudio(fileName: "sectionEnd", fileExtension: "m4a")
                            await delay(seconds: 7.0)                            
                        case "meditationLong":
                            player.playAudio(fileName: "meditation", fileExtension: "m4a",playForDuration: TimeInterval(currentSession.meditationTime) * 60,fade: true)
                                                        
                        default :
                            break
                                                    
                        }
                    }
                    
                    sessionTimer?.invalidate()
                    sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        if totalCycleTime  > 0 {
                            totalCycleTime  -= 1
                            totalTimeStr = formatTime(time: totalCycleTime)
                        } else {
                            sessionTimer?.invalidate()
                        }
                    }
                    cycleTimer?.invalidate()
                    cycleTimer = Timer.scheduledTimer(withTimeInterval:timeInterval, repeats: true) { _ in
                        if count  > 0 {
                            count  -= 1
                        } else {
                            cycleTimer?.invalidate()
                            currentIndex += 1
                            startSession()
                        }
                    }
                } else {
                    cycleTimer?.invalidate()
                    cycleTimer = nil
                    sessionTimer?.invalidate()
                    sessionTimer = nil
                    currentIndex = 0
                    playIndex = 0
                    count = playSessionValues[currentIndex].duration
                    total = playSessionValues[currentIndex].duration
                    isPlaying = false
                    breathLabel = true
                    totalCycleTime = setTotalSessionTime(selectedSession: currentSession)
                    totalTimeStr = formatTime(time: totalCycleTime)
                    currentCycleCount = 1
                    
                }
            }
        }
     }

    private func delay(seconds: TimeInterval) async {
        
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    func sessionSetSelected(selectedSession: Session) {
        
        setCycleData(selectedSession: selectedSession)
        totalCycleTime = setTotalSessionTime(selectedSession: selectedSession)
        totalTimeStr = formatTime(time:totalCycleTime )
        for session in sessions {
            session.saved = false
            if session.id == self.selectedSession?.id {
                session.saved = true
                totalCycles = session.cycles.count
            }
        }
    }
    

    func setCycleData(selectedSession: Session) {
        playSessionValues.removeAll()
        totalCycleTime = 0
        currentIndex = 0
        
        var playInfo = SessionPlayInfo()
        for cycle in selectedSession.cycles {
            
            playInfo = SessionPlayInfo(displayLabel: .breath,duration: cycle.breaths)
            playSessionValues.append(playInfo)
            playInfo = SessionPlayInfo(displayLabel: .time, audioStr: "meditation", extType: "m4a", duration: cycle.breathHold, interval: 1.0, fadeAudio: true)
            playSessionValues.append(playInfo)
            playInfo = SessionPlayInfo(displayLabel: .time, audioStr: "recoveryBreath", extType: "m4a", duration: cycle.finalHold, interval: 1.0)
            playSessionValues.append(playInfo)
            playInfo = SessionPlayInfo(displayLabel: .time, audioStr: "sectionEnd", extType: "m4a", duration: Int(0), interval: 1.0)
            playSessionValues.append(playInfo)
        }
        if selectedSession.meditationTime > 0 {
            playInfo = SessionPlayInfo(displayLabel: .time, audioStr: "meditationLong", extType: "m4a", duration: selectedSession.meditationTime * 60, interval: 1.0, fadeAudio: true)
            playSessionValues.append(playInfo)
            
        }
        
        for item in playSessionValues {
            print(item)
        }

    }
    
    func setTotalSessionTime(selectedSession:Session) -> Double
    {
        var totalTime : Double = 0
        for cycle in selectedSession.cycles {
            totalTime += Double(cycle.breaths) * (cycle.inhale + cycle.exhale) + Double(cycle.breathHold) + Double(cycle.finalHold) + 24
            print(totalTime)
            print("Breath Time:\(Double(cycle.breaths) * (cycle.inhale + cycle.exhale))  Breath Hold:\(Double(cycle.breathHold))  Final Hold:\(Double(cycle.finalHold))")
        }
        totalTime += Double(selectedSession.cycles.count - 1) * 3.0
        if selectedSession.playMeditaion == true {
            
            totalTime += Double(selectedSession.meditationTime * 60)

        }
        totalTimeStr = formatTime(time: totalTime)
        return totalTime
    }
    
    func formatTime(time : Double) -> String {
        
        if time >= 3600 {
            
            let hrs = Int(time) / 3600
            let min = Int(time - Double(hrs * 3600)) / 60
            let sec = Int(time - Double(hrs * 3600)) % 60
            return String(format:"%0i:%02i:%02i", hrs,min, sec)
            
        } else if time < 3600 && time >= 600 {
            
            let min = Int(time) / 60
            let sec = Int(time) % 60
            return String(format:"%02i:%02i", min, sec)
            
        } else {
            
            let min = Int(time) / 60
            let sec = Int(time) % 60
            return String(format:"%0i:%02i", min, sec)
        }
    }
}

extension View {
     public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
         let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
         return clipShape(roundedRect)
              .overlay(roundedRect.strokeBorder(content, lineWidth: width))
     }
 }
  




