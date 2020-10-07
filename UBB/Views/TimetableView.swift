//
//  ContentView.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 30/09/2020.
//

import SwiftUI

struct TimetableView: View {
    @EnvironmentObject var userSettings: UserSettings
    @FetchRequest(entity: Course.entity(), sortDescriptors: []) var timetable: FetchedResults<Course>
    
    var body: some View {
        NavigationView {
            VStack {
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
                                            if self.userSettings.weekViewType == .both, let week = course.frequency?.last, let number = Int(String(week)) {
                                                Text("week \(number)")
                                            }
                                        }
                                        .frame(width: UIScreen.main.bounds.width * 0.15)
                                        Divider()
                                        VStack(alignment: .leading) {
                                            Text("\(course.type?.uppercased() ?? ""): \(course.name ?? "")")
                                            Text(course.teacher ?? "")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .animation(.default)
                .navigationBarTitle("Timetable")
                .navigationBarItems(leading: EmptyView(), trailing: EmptyView()) // the fuck
            }
        }
    }
}
