import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timetableService: TimetableService
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingView<Year>()) {
                    Text("Year \(self.timetableService.year.map { "(\($0.id))" } ?? "")")
                }
                NavigationLink(destination: SettingView<Group>()) {
                    Text("Group \(self.timetableService.group.map { "(\($0.id))" } ?? "")")
                }
                .disabled(self.timetableService.year == nil)
                NavigationLink(destination: SettingView<Semigroup>()) {
                    Text("Semigroup \(self.timetableService.semigroup.map { "(\($0.id))" } ?? "")")
                }
                .disabled(
                    self.timetableService.group == nil ||
                    self.timetableService.semigroup?.id == "default"
                )
            }
            .navigationTitle(Text("Settings"))
        }
    }
}

struct SettingView<T: Item>: View {
    @EnvironmentObject var timetableService: TimetableService
    @Environment(\.presentationMode) var presentationMode
    
    @State var items: [[T]] = []

    private func onYearPress(_ item: T) {
        self.timetableService.year = item as? Year
    }

    private func onGroupPress(_ item: T) {
        self.timetableService.getSemigroups(year: self.timetableService.year!, group: item as! Group) { semigroups in
            if let semigroups = semigroups {
                DispatchQueue.main.async {
                    if semigroups.count == 0 {
                        self.timetableService.semigroup = Semigroup.default
                    }
                    self.timetableService.group = item as? Group
                }
            }
        }
    }

    private func onSemigroupPress(_ item: T) {
        self.timetableService.semigroup = item as? Semigroup
    }

    private func onAppearForYear() {
        self.timetableService.getYears { years in
            if let years = years {
                self.items = years as! [[T]]
            }
        }
    }

    private func onAppearForGroup() {
        self.timetableService.getGroups(for: self.timetableService.year!) { groups in
            if let groups = groups {
                self.items = [groups] as! [[T]]
            }
        }
    }

    private func onAppearForSemigroup() {
        self.timetableService.getSemigroups(
            year: self.timetableService.year!,
            group: self.timetableService.group!
        ) { semigroups in
            if let semigroups = semigroups {
                self.items = [semigroups] as! [[T]]
            }
        }
    }
    
    var yearList: some View {
        List {
            ForEach(Array(zip(self.items.indices, self.items)), id: \.0) { index, items in
                Section(header: Text(items[0].value)) {
                    ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                        Button(action: {
                            self.onYearPress(item)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Year \(index + 1)")
                        }
                    }
                }
            }
        }
    }
    
    var list: some View {
        List {
            ForEach(self.items.count > 0 ? self.items[0] : [], id: \.id) { item in
                Button(action: {
                    switch T.self {
                        case is Group.Type:
                            self.onGroupPress(item)
                        case is Semigroup.Type:
                           self.onSemigroupPress(item)
                        default:
                            ()
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text(item.value)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if T.self is Year.Type {
                self.yearList
            } else {
                self.list
            }
        }
        .navigationTitle(NSStringFromClass(T.self).components(separatedBy: ".").last!)
        .onAppear {
            switch T.self {
                case is Year.Type:
                    self.onAppearForYear()
                case is Group.Type:
                    self.onAppearForGroup()
                case is Semigroup.Type:
                    self.onAppearForSemigroup()
                default:
                    ()
            }
        }
    }
}
