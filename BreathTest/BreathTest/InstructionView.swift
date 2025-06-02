//
//  Settings.swift
//  BreathTest
//
//  Created by John Kine on 2024-12-04.
//

import SwiftUI

struct InstructionView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    
    
    var body: some View {
        Text("Settings")
        
    }
    
}
   

#Preview {
    InstructionView()
}
