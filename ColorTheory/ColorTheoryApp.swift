//
//  ColorTheoryApp.swift
//  ColorTheory
//
//  Created by Magesh Sridhar on 4/13/21.
//

import SwiftUI

@main
struct ColorTheoryApp: App {
    @StateObject private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
                .preferredColorScheme(.dark)
        }
    }
}
