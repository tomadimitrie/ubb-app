//
//  ContentView.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 30/09/2020.
//

import SwiftUI

struct TimetableView: View {
    @EnvironmentObject var userSettings: UserSettings
        
    var body: some View {
        NavigationView {
            List {
                if let timetable = self.userSettings.timetable {
                    ForEach(Array(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"].enumerated()), id: \.element) { index, day in
                        Section(header: Text(day)) {
                            ForEach(timetable[index], id: \.id) { course in
                                HStack {
                                    VStack {
                                        Text("\(course.startHour):00")
                                        Text("\(course.endHour):00")
                                        if let week = course.frequency.last, let number = Int(String(week)) {
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
            .navigationBarTitle("Timetable")
            .navigationBarItems(leading: EmptyView(), trailing: EmptyView()) // the fuck
        }
    }
}
