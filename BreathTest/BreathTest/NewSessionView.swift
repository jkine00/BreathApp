//
//  NewSessionView.swift
//  BreathTest
//
//  Created by John Kine on 2024-11-14.
//

import SwiftUI
import SwiftData

struct NewSessionView: View {
    
    @AppStorage("isDarkModel") var isDarkModel: Bool = UserDefaults.standard.bool(forKey: "isDarkModel")
    
    let blankCycle = Cycle(id: UUID(), breaths: 20, inhale: 1.0, exhale: 1.0, breathHold: 30, finalHold: 10)
    
    @Environment(\.modelContext) private var context
    
    @Query(sort:\Session.title) private var sessions: [Session]
    @Environment(\.dismiss) var dismiss
    @State var title: String = ""
    var body: some View {
        NavigationStack {
            Form {
                TextField("Session Title", text: $title)
                Button("Create Session") {
                    let newSession = Session(title: title)
                    newSession.cycles.append(blankCycle)
                   
                    context.insert(newSession)
                    if sessions.count == 1 {
                        newSession.saved = true
                    }
                    dismiss()
                }
                .frame(maxWidth:.infinity,alignment: .trailing)
                .buttonStyle(.borderedProminent)
                .padding(.vertical)
                .disabled(title.isEmpty)
                .navigationTitle("New Session")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss() }
                    }
                }
            }
        }
    }
}

#Preview {
    NewSessionView()
}
