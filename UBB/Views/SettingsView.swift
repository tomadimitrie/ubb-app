//
//  SettingsView.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 02/10/2020.
//

import SwiftUI

enum Setting: String {
    case year, group, semigroup
}

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingView(setting: .year)) {
                    Text("Year \(self.userSettings.year.map { "(\($0.id))" } ?? "")")
                }
                NavigationLink(destination: SettingView(setting: .group)) {
                    Text("Group \(self.userSettings.group.map { "(\($0.id))" } ?? "")")
                }
                .disabled(self.userSettings.year == nil)
                NavigationLink(destination: SettingView(setting: .semigroup)) {
                    Text("Semigroup \(self.userSettings.semigroup.map { "(\($0.id))" } ?? "")")
                }
                .disabled(self.userSettings.group == nil)
            }
            .navigationBarTitle(Text("Settings"))
        }
    }
}

struct SettingView: View {
    let setting: Setting
    
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State var items: [Item] = []
    
    var body: some View {
        List {
            ForEach(self.items, id: \.id) { item in
                Button(action: {
                    switch self.setting {
                        case .year:
                            self.userSettings.year = item
                        case .group:
                            self.userSettings.group = item
                        case .semigroup:
                            self.userSettings.semigroup = item
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text(item.value)
                }
            }
        }
        .navigationTitle(self.setting.rawValue.capitalized)
        .onAppear {
            switch self.setting {
                case .year:
                    TimetableService.shared.getYears { years in
                        if let years = years {
                            self.items = years
                        }
                    }
                case .group:
                    TimetableService.shared.getGroups(for: self.userSettings.year!) { groups in
                        if let groups = groups {
                            self.items = groups
                        }
                    }
                case .semigroup:
                    self.items = [Item(id: "1", value: "1"), Item(id: "2", value: "2")]
            }
        }
    }
}
