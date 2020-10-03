//
//  UserSettings.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 02/10/2020.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var timetable: [Timetable]? = nil
    
    @UserDefault("year") var year: Year? = nil {
        didSet {
            self.timetable = nil
        }
    }
    
    @UserDefault("group") var group: Group? = nil {
        didSet {
            self.updateTimetable()
        }
    }
    
    @UserDefault("semigroup") var semigroup: Semigroup? = nil {
        didSet {
            self.updateTimetable()
        }
    }
    
    func updateTimetable() {
        if let year = self.year, let group = self.group {
            TimetableService.shared.getTimetable(year: year, group: group) { timetable in
                if let timetable = timetable {
                    var array: [Timetable] = []
                    var temp: Timetable = [timetable[0]]
                    for course in timetable[1...] {
                        if let semigroup = self.semigroup {
                            if course.group.split(separator: "/").count == 2, let last = course.group.last, String(last) != semigroup.id {
                                continue
                            }
                        }
                        if course.day == temp[0].day {
                            temp.append(course)
                        } else {
                            array.append(temp)
                            temp = [course]
                        }
                    }
                    array.append(temp)
                    DispatchQueue.main.async {
                        self.timetable = array
                    }
                }
            }
        }
    }
    
    init() {
        self.updateTimetable()
    }
}
