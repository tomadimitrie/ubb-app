//
//  Course+Extensions.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 21.02.2022.
//

import Foundation

extension Course: Identifiable {
    public var id: String {
        let timetableService = TimetableService.shared
        return "\(timetableService.year as Any)_\(timetableService.group as Any)_\(timetableService.semigroup as Any)_\(name)_\(room)_\(teacher)_\(day)_\(startHour)_\(startMinute)_\(endHour)_\(endMinute)_\(type)_\(frequency)"
    }
}
