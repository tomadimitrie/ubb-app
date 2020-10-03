//
//  UBBApp.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 30/09/2020.
//

import SwiftUI

@main
struct UBBApp: App {
    let userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TimetableView()
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Timetable")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
            }
            .environmentObject(self.userSettings)
        }
    }
}
