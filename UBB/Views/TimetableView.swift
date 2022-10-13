import SwiftUI
import Sentry

struct TimetableView: View {
    @EnvironmentObject private var timetableService: TimetableService
    @FetchRequest(
        entity: Course.entity(),
        sortDescriptors: [
            NSSortDescriptor(key: "startHour", ascending: true)
        ]
    ) private var timetable: FetchedResults<Course>
    @FetchRequest(
        entity: EditedCourse.entity(),
        sortDescriptors: []
    ) private var editedCourses: FetchedResults<EditedCourse>
    @Binding var activeTab: Int
    @State private var placeholderMessage: String?
    @State private var currentlyEditingCourse: Course?
    @State private var isHideCoursesShown = false
    
    private var renderPlaceholder: some View {
        SwiftUI.Group {
            Text("It's lonely here")
            if let placeholderMessage = placeholderMessage {
                Text(placeholderMessage)
            }
            Text("Go to Settings to configure your timetable")
            Button(action: {
                self.activeTab = 1
            }) {
                Text("Take me there")
            }
            .padding()
        }
    }

    private var renderPicker: some View {
        // top picker to select week
        Picker(selection: self.$timetableService.weekViewType, label: Text("Week view")) {
            Text("Week 1")
                .tag(WeekViewType.one)
            Text("Week 2")
                .tag(WeekViewType.two)
            Text("Both weeks")
                .tag(WeekViewType.both)
        }
        .padding([.top, .leading, .trailing])
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private func formatNumber(_ number: Int16) -> String {
        switch number {
        case 0...9:
            return "0\(number)"
        default:
            return String(number)
        }
    }

    private func renderCell(_ course: Course) -> some View {
        let existingCourse = editedCourses.first {
            $0.id == course.id
        }
        var view: some View {
            SwiftUI.Group {
                if
                    let existingCourse = existingCourse,
                    existingCourse.isHidden
                {
                    if timetableService.showHidden {
                        HStack {
                            Spacer()
                            Text("hidden")
                                .font(.system(size: 10))
                            Spacer()
                        }
                        .frame(height: 5)
                    }
                } else {
                    HStack {
                        VStack {
                            Text("\(formatNumber(course.startHour)):\(formatNumber(course.startMinute))")
                            Text("\(formatNumber(course.endHour)):\(formatNumber(course.endMinute))")
                            if
                                // only show when both weeks are selected
                                timetableService.weekViewType == .both,
                                let week = course.frequency.last,
                                let number = Int(String(week))
                            {
                                Text("week \(number)")
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.15)
                        Divider()
                        VStack(alignment: .leading) {
                            Text("\(course.type.uppercased()): \(course.name)")
                            Text(course.teacher)
                            Text("Room: \(course.room)")
                        }
                    }
                    .if(course.type == "Curs") {
                        $0.listRowBackground(timetableService.courseColor)
                            .if(timetableService.courseColor?.isLight ?? false) {
                                $0.foregroundColor(.black)
                            }
                    }
                    .if(course.type == "Seminar") {
                        $0.listRowBackground(timetableService.seminarColor)
                            .if(timetableService.seminarColor?.isLight ?? false) {
                                $0.foregroundColor(.black)
                            }
                    }
                    .if(course.type == "Laborator") {
                        $0.listRowBackground(timetableService.labColor)
                            .if(timetableService.labColor?.isLight ?? false) {
                                $0.foregroundColor(.black)
                            }
                    }
                }
            }
        }
        return view
            .swipeActions {
                Button {
                    currentlyEditingCourse = course
                } label: {
                    Label("Edit", systemImage: "slider.horizontal.3")
                }
                .tint(.yellow)
            }
    }

    private var renderList: some View {
        List {
            ForEach(Day.allCases, id: \.self) { day in
                Section(header: Text(day.rawValue.capitalized)) {
                    ForEach(timetable.filter { $0.day == day.rawValue }, id: \.id) { course in
                        if timetableService.validateCourse(course) {
                            self.renderCell(course)
                        }
                    }
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 10)
    }

    var body: some View {
        NavigationView {
            VStack {
                // the app is newly installed - show a placeholder
                if placeholderMessage != nil {
                    renderPlaceholder
                } else {
                    renderPicker
                    renderList
                }
            }
            .animation(.default, value: UUID())
            .navigationTitle("Timetable")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Redownload") {
                        Task {
                            await timetableService.updateTimetable()
                        }
                    }
                    // if the settings are not set yet, we cannot download the timetable
                    // because we don't know which one
                    .disabled(!timetableService.areSettingsSet)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") {
                        isHideCoursesShown = true
                    }
                }
            }
            .onAppear {
                Task {
                    let values = (timetableService.year, timetableService.group, timetableService.semigroup)
                    switch values {
                    case (.some, nil, nil):
                        placeholderMessage = "Year is set, but group and semigroup are not"
                    case (.some, .some, nil):
                        if await timetableService.hasSemigroups {
                            placeholderMessage = "Year and group are set, but semigroup is not"
                        } else {
                            placeholderMessage = nil
                        }
                    case (nil, nil, nil):
                        placeholderMessage = "Year, group and semigroup are not set"
                    default:
                        placeholderMessage = nil
                    }
                }
            }
            .sheet(item: $currentlyEditingCourse, onDismiss: {
                currentlyEditingCourse = nil
            }) { course in
                EditCourseView(
                    course: course
                )
                .environmentObject(timetableService)
            }
            .sheet(isPresented: $isHideCoursesShown) {
                HideCoursesView()
                    .environmentObject(timetableService)
            }
        }
    }
}
