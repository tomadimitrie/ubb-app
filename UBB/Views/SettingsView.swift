//
//  SettingsView.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 02/10/2020.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingView<Year>()) {
                    Text("Year \(self.userSettings.year.map { "(\($0.id))" } ?? "")")
                }
                NavigationLink(destination: SettingView<Group>()) {
                    Text("Group \(self.userSettings.group.map { "(\($0.id))" } ?? "")")
                }
                .disabled(self.userSettings.year == nil)
                NavigationLink(destination: SettingView<Semigroup>()) {
                    Text("Semigroup \(self.userSettings.semigroup.map { "(\($0.id))" } ?? "")")
                }
                .disabled(self.userSettings.group == nil || self.userSettings.semigroup?.id == "default")
            }
            .navigationBarTitle(Text("Settings"))
        }
    }
}

struct SettingView<T: Item>: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State var items: [T] = []
    
    var body: some View {
        List {
            ForEach(self.items, id: \.id) { item in
                Button(action: {
                    switch T.self {
                        case is Year.Type:
                            self.userSettings.year = item as? Year
                        case is Group.Type:
                            TimetableService.shared.getSemigroups(year: self.userSettings.year!, group: item as! Group) { semigroups in
                                if let semigroups = semigroups {
                                    DispatchQueue.main.async {
                                        if semigroups.count == 0 {
                                            self.userSettings.semigroup = Semigroup.default
                                        }
                                        self.userSettings.group = item as? Group
                                    }
                                }
                            }
                        case is Semigroup.Type:
                            self.userSettings.semigroup = item as? Semigroup
                        default:
                            ()
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text(item.value)
                }
            }
        }
        .navigationTitle(NSStringFromClass(T.self).components(separatedBy: ".").last!)
        .onAppear {
            switch T.self {
                case is Year.Type:
                    TimetableService.shared.getYears { years in
                        if let years = years {
                            self.items = years as! [T]
                        }
                    }
                case is Group.Type:
                    TimetableService.shared.getGroups(for: self.userSettings.year!) { groups in
                        if let groups = groups {
                            self.items = groups as! [T]
                        }
                    }
                case is Semigroup.Type:
                    TimetableService.shared.getSemigroups(
                        year: self.userSettings.year!,
                        group: self.userSettings.group!
                    ) { semigroups in
                        if let semigroups = semigroups {
                            self.items = semigroups as! [T]
                        }
                    }
                default:
                    ()
            }
        }
    }
}
