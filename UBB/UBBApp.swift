//
//  UBBApp.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 30/09/2020.
//

import SwiftUI

@main
struct UBBApp: App {
    let userSettings = UserSettings.shared
    let persistenceController = PersistenceController.shared
    
    @State var activeTab: Int = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: self.$activeTab) {
                TimetableView(activeTab: self.$activeTab)
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Timetable")
                    }
                    .tag(0)
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .tag(1)
            }
            .environmentObject(self.userSettings)
            .environment(\.managedObjectContext, self.persistenceController.container.viewContext)
        }
    }
}
