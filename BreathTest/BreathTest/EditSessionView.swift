//
//  EditBookView.swift
//  BreathTest
//
//  Created by John Kine on 2024-11-16.
//

import SwiftUI

class SessionSettings: ObservableObject {
    @Published var meditationTrack:String?
}

struct EditSessionView: View {
    
    
    @StateObject var trackSelected = SessionSettings()    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
        
    let session: Session
    @State var title = ""
    @State var totalCycleTime:Double = 0
    @State var breaths = 20
    @State var inHale = 0.5
    @State var exHale = 0.5
    @State var breathold = 10
    @State var finalHold = 10
    @State var playMeditaion = false
    @State var meditationTime = 0
    @State var tempMeditationTime = 0
    @State var meditationStr = "Default Track"
    @State var selectMeditation = false
    @State var editingIndexNumber: Int?
    @State var tempCycles = Array<Cycle>() {
        didSet {
            totalCycleTime = 0
            for cycle in session.cycles {
                
                totalCycleTime += Double(cycle.breaths) * (cycle.inhale + cycle.exhale) + Double(cycle.breathHold) + Double(cycle.finalHold)
            }
        }
    }
    @State var changedMeditation = false
    
    let charFont:Font = .system(size: UIScreen.main.bounds.width * 0.032)
    let numberFont:Font = .system(size: UIScreen.main.bounds.width * 0.032,design:.monospaced)
    
    
    
    var body: some View {
    
        GeometryReader { geometry in
            GroupBox {
                VStack {
                    LabeledContent {
                        TextField("", text: $title)
                            .font(UIScreen.main.bounds.width < 400 ? .subheadline :charFont)
                    } label: {
                        Text("Title").foregroundStyle(.secondary)
                            
                    }
                    Divider()
                    VStack {
                        Toggle("Play meditaion?", isOn: $playMeditaion)
                            .onChange(of: playMeditaion) { old,value in
                                if !playMeditaion {
                                    tempMeditationTime = 0
                                    meditationTime = 0
                                } else {
                                    if meditationTime == 0 {
                                        meditationTime = 1
                                    }
                                    tempMeditationTime = meditationTime
                                }
                            }
                            .font(charFont)
                        if playMeditaion {
                            VStack {
                                HStack {
                                    Stepper("Meditaion Time (Min.):", value: $meditationTime, in: 1...60)
                                        .font(charFont)
                                        .onChange(of: meditationTime) { value, oldVlaue in
                                            tempMeditationTime = meditationTime
                                        }
                                    Text(digitOnlyStr(value: meditationTime))
                                        .font(numberFont)  //(.system(.headline, design: .monospaced))
                                        .padding(6)
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 1))
                                }
                                HStack {
                                    Button ("Select Meditation") {
                                        selectMeditation = true
                                    }
                                    .font(UIScreen.main.bounds.width < 400 ? charFont :.subheadline)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    Text("\(meditationStr)")
                                        .font(UIScreen.main.bounds.width < 400 ? charFont :.subheadline)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .sheet(isPresented: $selectMeditation) {
                                MeditationTrackSelection()
                                    .presentationDetents([.large])
                                    .font(charFont)
                            }
                            .font(charFont)
                            .environmentObject(trackSelected)
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    Divider()
                    HStack {
                        
                        Text(editingIndexNumber != nil ? "Edit Cycle: \(editingIndexNumber! + 1)" : "Total Cycles: \(tempCycles.count)")
                            .frame( alignment: .leading)
                        HStack {
                            Button (editingIndexNumber == nil ? "Add" : "Cancel") {
                                if editingIndexNumber != nil {
                                    editingIndexNumber = nil
                                } else {
                                    tempCycles.append(Cycle(breaths: breaths, inhale: inHale, exhale: exHale, breathHold: breathold, finalHold: finalHold))
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            Button (editingIndexNumber == nil ? "New" : "Replace") {
                                if let editIndexNumber = editingIndexNumber {
                                    tempCycles[editIndexNumber].breaths = breaths
                                    tempCycles[editIndexNumber].inhale = inHale
                                    tempCycles[editIndexNumber].exhale = exHale
                                    tempCycles[editIndexNumber].breathHold = breathold
                                    tempCycles[editIndexNumber].finalHold = finalHold
                                    editingIndexNumber = nil
                                } else {
                                    breaths = 20
                                    inHale = 2
                                    exHale = 2
                                    breathold = 10
                                    finalHold = 5
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .font(UIScreen.main.bounds.width < 400 ? charFont :.subheadline)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Divider()
                    
                        HStack {
                            Stepper("Breaths:", value: $breaths, in: 20...100)
                            Text(digitOnlyStr(value: breaths))
                                .font(numberFont)
                                .padding(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 1))
                        }
                        
                        HStack {
                            Stepper("Inhale:", value: $inHale, in: 1...30,step: 1)    //, in: 4...12, step: 0.25)
                            Text("\(inhaleExhaleStr(time: inHale))")
                                .font(numberFont)
                                .padding(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 1))
                                .frame(alignment: .center)
                        }
                        HStack {
                            Stepper("Exhale:", value: $exHale, in: 1...30,step: 1)
                            Text("\(inhaleExhaleStr(time: exHale))")
                                .font(numberFont)
                                .padding(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 1))
                                .frame(alignment: .center)
                        }
                        HStack {
                            Stepper("Breath Hold:", value: $breathold, in: 10...600)
                            Text("\(timeStr(time: breathold))")
                                .font(numberFont)
                                .padding(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 1))
                                .frame(alignment: .center)
                        }
                        HStack {
                            Stepper("Final Hold:", value: $finalHold, in: 5...60)
                            Text("\(timeStr(time: finalHold))")
                                .font(numberFont)
                                .padding(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary, lineWidth: 1))
                                .frame(alignment: .center)
                        }
                    
                    Divider()
                    HStack() {
                        Text("Total Session Time: ")
                            .fontWeight(.semibold)
                        Text("\(longTimeStr(time: Int(totalCycleTime) + meditationTime * 60))")
                            .font(numberFont)
                        Text("Hrs:Min:Sec")
                            .font(charFont)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    List {
                        ForEach(tempCycles.indices, id: \.self) { idx in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Cycle:")
                                        .font(charFont)
                                        .foregroundStyle(.secondary)
                                    Text("\(idx + 1)")
                                        .font(numberFont)
                                        .foregroundStyle(.secondary)
                                    Text("Breaths:")
                                    Text("\(tempCycles[idx].breaths)")
                                        .font(numberFont)
                                }
                                Grid() {
                                    GridRow {
                                        Text("Breath Hold:")
                                        Text("\(timeStr(time: tempCycles[idx].breathHold))")
                                            .font(numberFont)
                                        Text("min:sec")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("Inhale: ")
                                        Text("\(inhaleExhaleStr(time: tempCycles[idx].inhale))")
                                            .font(numberFont)
                                        Text("sec")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    GridRow {
                                        Text("Final Hold:")
                                        Text("\(timeStr(time:  tempCycles[idx].finalHold))")
                                            .font(numberFont)
                                        Text("min:sec")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("Exhale:")
                                        Text("\(inhaleExhaleStr(time: tempCycles[idx].exhale))")
                                            .font(numberFont)
                                        Text("sec")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                          
                            
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                breaths = tempCycles[idx].breaths
                                inHale = tempCycles[idx].inhale
                                exHale = tempCycles[idx].exhale
                                breathold = tempCycles[idx].breathHold
                                finalHold = tempCycles[idx].finalHold
                                editingIndexNumber = idx
                            }
                        }
                        .onDelete { indexSet in
                            withAnimation {
                                tempCycles.remove(atOffsets: indexSet)
                                editingIndexNumber = nil
                            }
                        }
                    }
                    
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .listStyle(.plain)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                }
            }
        }
        .font(charFont)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .textFieldStyle(.roundedBorder)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if changed {
                Button("Update") {
                    session.title = title
                    session.playMeditaion = playMeditaion
                    session.meditationTime = tempMeditationTime
                    if let newMeditationTrack = trackSelected.meditationTrack {
                        session.meditaionTrack = newMeditationTrack
                        print(newMeditationTrack)
                    }
                    session.cycles = tempCycles
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .font(UIScreen.main.bounds.width < 400 ? charFont :.subheadline)
        .onAppear {
            print("Width: \(UIScreen.main.bounds.width) Hight: \(UIScreen.main.bounds.height)")
            
            title = session.title
            tempCycles = session.cycles
            meditationTime = session.meditationTime
            tempMeditationTime = meditationTime
            playMeditaion = session.playMeditaion
            meditationStr = session.meditaionTrack
            breaths = tempCycles.last?.breaths ?? 20
            inHale = tempCycles.last?.inhale ?? 1.0
            exHale = tempCycles.last?.exhale ?? 1.0
            breathold = tempCycles.last?.breathHold ?? 10
            finalHold = tempCycles.last?.finalHold ?? 10
            
            
            
             
             var cycleTime : Double = 0
             for cycle in session.cycles {
                 cycleTime += Double(cycle.breaths) * (cycle.inhale + cycle.exhale) + Double(cycle.breathHold) + Double(cycle.finalHold)
             }
            cycleTime += Double(session.meditationTime * 60)

        }
        .onChange(of: trackSelected.meditationTrack) {
            meditationStr = trackSelected.meditationTrack ?? "Default Track"
            print("meditationStr:\(meditationStr)")
            changedMeditation = true
        }
        var changed: Bool {
            title != session.title && title != "" ||
            playMeditaion != session.playMeditaion ||
            meditationTime != session.meditationTime ||
            meditationStr != session.meditaionTrack ||
            tempCycles != session.cycles ||
            changedMeditation
        }
    }
    
    func timeStr(time:Int ) -> String {
        let min = time/60
        let sec = time%60
        return String(format: "%01d:%02d", min, sec)
    }
        
    func longTimeStr(time:Int ) -> String {
        let hr = time/3600
        let min = (time%3600)/60
        let sec = (time%3600)%60
        return String(format: "%01d:%02d:%02d",hr, min, sec)
    }
   
    func digitOnlyStr(value:Int) -> String {
        switch value {
        case 0...9:
            return "  \(value)"
        case 10...99:
            return " \(value)"
        default:
            return "\(value)"
        }
    }
    
    func inhaleExhaleStr(time:Double) -> String {
        switch time {
        case 0...9.9:
            return String(format: " %.1f", time)
        default:
            return String(format: "%.1f", time)
        }
    }
    
   
}


#Preview {
    SessionListView()
        .modelContainer(for: Session.self,inMemory: true)
}
