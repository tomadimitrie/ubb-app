import SwiftUI
import Collections

struct SettingsView: View {
    @EnvironmentObject var timetableService: TimetableService
    
    @State private var isColorPickerSheetShown = false
    @State private var courseColor = Color.black
    @State private var seminarColor = Color.black
    @State private var labColor = Color.black
    @State private var showHidden = false

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SettingView<Year>()) {
                    Text("Year \(timetableService.year.map { "(\($0.id))" } ?? "")")
                }
                NavigationLink(destination: SettingView<Group>()) {
                    Text("Group \(timetableService.group.map { "(\($0.id))" } ?? "")")
                }
                .disabled(timetableService.year == nil)
                NavigationLink(destination: SettingView<Semigroup>()) {
                    Text("Semigroup \(timetableService.semigroup.map { "(\($0.id))" } ?? "")")
                }
                .disabled(
                    timetableService.group == nil ||
                    timetableService.semigroup?.id == "default"
                )
                ColorPicker(
                    "Course color",
                    selection: $courseColor
                )
                .onChange(of: courseColor) { courseColor in
                    timetableService.courseColor = courseColor
                }
                ColorPicker(
                    "Seminar color",
                    selection: $seminarColor
                )
                .onChange(of: seminarColor) { seminarColor in
                    timetableService.seminarColor = seminarColor
                }
                ColorPicker(
                    "Lab color",
                    selection: $labColor
                )
                .onChange(of: labColor) { labColor in
                    timetableService.labColor = labColor
                }
                Toggle(isOn: $showHidden) {
                    Text("Show hidden")
                }
                .onChange(of: showHidden) { showHidden in
                    timetableService.showHidden = showHidden
                }
            }
            .navigationTitle(Text("Settings"))
            .onAppear {
                courseColor = timetableService.courseColor ?? Color.black
                seminarColor = timetableService.seminarColor ?? Color.black
                labColor = timetableService.labColor ?? Color.black
                showHidden = timetableService.showHidden
            }
        }
    }
}

struct ColorPickerView: View {
    @State private var color = Color.white

    var body: some View {
        ColorPicker("a", selection: self.$color)
    }
}

struct SettingView<T: Item>: View {
    @EnvironmentObject var timetableService: TimetableService
    @Environment(\.presentationMode) var presentationMode
    
    @State var items: [T] = []

    private func onYearPress(_ item: T) {
        timetableService.year = item as? Year
    }

    private func onGroupPress(_ item: T) {
        Task {
            if let semigroups = try? await timetableService.getSemigroups(year: self.timetableService.year!, group: item as! Group) {
                DispatchQueue.main.async {
                    if semigroups.count == 0 {
                        timetableService.semigroup = Semigroup.default
                    }
                    timetableService.group = item as? Group
                }
            }
        }
    }

    private func onSemigroupPress(_ item: T) {
        timetableService.semigroup = item as? Semigroup
    }

    private func onAppearForYear() {
        Task {
            if let years = try? await timetableService.getYears() {
                items = years as! [T]
            }
        }
    }

    private func onAppearForGroup() {
        Task {
            if let groups = try? await timetableService.getGroups(for: self.timetableService.year!) {
                items = groups as! [T]
            }
        }
    }

    private func onAppearForSemigroup() {
        Task {
            if let semigroups = try? await timetableService.getSemigroups(
                year: timetableService.year!,
                group: timetableService.group!
            ) {
                self.items = semigroups as! [T]
            }
        }
    }
    
    var renderYearList: some View {
        let grouped = items.grouped(by: \.value)
        return List {
            ForEach(Array(grouped.keys), id: \.self) { key in
                Section(header: Text(key)) {
                    ForEach(grouped[key] ?? [], id: \.index) { item in
                        Button(action: {
                            onYearPress(item)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Year \(item.index + 1) (\(item.id))")
                        }
                    }
                }
            }
        }
    }
    
    var renderOtherList: some View {
        List {
            ForEach(items, id: \.id) { item in
                Button(action: {
                    switch T.self {
                        case is Group.Type:
                            self.onGroupPress(item)
                        case is Semigroup.Type:
                           self.onSemigroupPress(item)
                        default:
                            ()
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(item.value)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if T.self is Year.Type {
                self.renderYearList
            } else {
                self.renderOtherList
            }
        }
        .navigationTitle(NSStringFromClass(T.self).components(separatedBy: ".").last!)
        .onAppear {
            switch T.self {
                case is Year.Type:
                    onAppearForYear()
                case is Group.Type:
                    onAppearForGroup()
                case is Semigroup.Type:
                    onAppearForSemigroup()
                default:
                    ()
            }
        }
    }
}
