//
//  BreathTestApp.swift
//  BreathTest
//
//  Created by John Kine on 2024-11-14.
//

import SwiftUI
import SwiftData

@main
struct BreathTestApp: App {
    
    @Environment(\.modelContext) private var context
    @Query(sort:\Session.title) private var sessions: [Session]
    @EnvironmentObject var trackSelected: SessionSettings
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @State private var tabSelection:Int = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabSelection){
                NavigationView {
                    SessionListView()
                }
                .tabItem {
                    Image("Settings")
                    Text("Settings")
                }
                .tag(0)
                NavigationView {
                    BreatheView(tabSelection: $tabSelection)
                }
                .tabItem {
                    Image("Breathe")
                    Text("Breathe")
                        
                }
                .tag(1)
                NavigationView {
                    InstructionView()
                }
                
                .tabItem {
                    Image("Instructions")
                    Text("Instructions")
                }
                .tag(2)
            }
            .padding()
            .environment(\.horizontalSizeClass, .compact )
            .navigationViewStyle(StackNavigationViewStyle())
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: Session.self)
        
    }
    
    init () {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
            
    }
}
