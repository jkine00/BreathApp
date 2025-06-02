//
//  ContentView.swift
//  BreathTest
//
//  Created by John Kine on 2024-11-14.
//

import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var context  
    @Query(sort:\Session.title) private var sessions: [Session]
    @State var createNewSession: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView("Enter your first session", systemImage: "pencil.and.list.clipboard")
                } else {
                    List {
                        ForEach(sessions) { session in
                            NavigationLink {
                                EditSessionView(session: session)
                            } label: {
                                HStack(spacing:10) {
                                    VStack(alignment: .leading) {
                                        Text(session.title).font(.title2)
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let book = sessions[index]
                                context.delete(book)
                                if sessions.count == 1 || (!sessions.isEmpty && book.saved) {
                                    sessions[0].saved = true
                                }
                            }
                        }
                    }
                }
            }
  
            .listStyle(.plain)
            .navigationTitle("Sessions")
            .toolbar {
                Button {
                    isDarkMode.toggle()
                    
                } label: {
                    Image(systemName: isDarkMode ? "lightbulb.fill" : "lightbulb")
                }
                                
                Button {
                    createNewSession = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .imageScale(.large)
                }
                .sheet(isPresented: $createNewSession) {
                    NewSessionView()
                        .presentationDetents(.init([.medium]))
                }
            }
        }
    }
}

#Preview {
    SessionListView()
        .modelContainer(for: Session.self,inMemory: true)
}
