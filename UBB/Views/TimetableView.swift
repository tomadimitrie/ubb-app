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
    @Binding var activeTab: Int

    private var placeholder: some View {
        SwiftUI.Group {
            Text("It's lonely here")
            Text("Go to Settings to configure your timetable")
            Button(action: {
                self.activeTab = 1
            }) {
                Text("Take me there")
            }
            .padding()
        }
    }

    private var picker: some View {
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

    private func cell(_ course: Course) -> some View {
        HStack {
            VStack {
                Text("\(course.startHour):00")
                Text("\(course.endHour):00")
                if
                    self.timetableService.weekViewType == .both,
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
            }
        }
    }

    private var list: some View {
        List {
            ForEach(Day.allCases, id: \.self) { day in
                Section(header: Text(day.rawValue.capitalized)) {
                    ForEach(self.timetable.filter { $0.day == day.rawValue }, id: \.id) { course in
                        if self.timetableService.validateCourse(course) {
                            self.cell(course)
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if self.timetable.count == 0 {
                    self.placeholder
                } else {
                    self.picker
                    self.list
                }
            }
            .animation(.default)
            .navigationTitle("Timetable")
            .toolbar {
                Button("Redownload") {
                    SentrySDK.capture(message: "hello")
                    self.timetableService.updateTimetable()
                }
                .disabled(self.timetable.count == 0)
            }
        }
    }
}
