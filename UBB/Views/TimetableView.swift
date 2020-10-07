//
//  ContentView.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 30/09/2020.
//

import SwiftUI

struct TimetableView: View {
    @EnvironmentObject var userSettings: UserSettings
    @FetchRequest(
        entity: Course.entity(),
        sortDescriptors: [
            NSSortDescriptor(key: "startHour", ascending: true)
        ]
    ) var timetable: FetchedResults<Course>
    
    @Binding var activeTab: Int
    
    var body: some View {
        NavigationView {
            VStack {
                if timetable.count == 0 {
                    Text("It's lonely here")
                    Text("Go to Settings to configure your timetable")
                    Button(action: {
                        self.activeTab = 1
                    }) {
                        Text("Take me there")
                    }
                    .padding()
                } else {
                    Picker(selection: self.$userSettings.weekViewType, label: Text("Week view")) {
                        Text("Week 1").tag(WeekViewType.one)
                        Text("Week 2").tag(WeekViewType.two)
                        Text("Both weeks").tag(WeekViewType.both)
                    }
                    .padding()
                    .pickerStyle(SegmentedPickerStyle())
                    List {
                        ForEach(Day.allCases, id: \.self) { day in
                            Section(header: Text(day.rawValue.capitalized)) {
                                ForEach(self.timetable.filter { $0.day == day.rawValue }, id: \.id) { course in
                                    if self.userSettings.validateCourse(course) {
                                        HStack {
                                            VStack {
                                                Text("\(course.startHour):00")
                                                Text("\(course.endHour):00")
                                                if self.userSettings.weekViewType == .both, let week = course.frequency.last, let number = Int(String(week)) {
                                                    Text("week \(number)")
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
                                }
                            }
                        }
                    }
                }
            }
            .animation(.default)
            .navigationBarTitle("Timetable")
        }
    }
}
