//
//  TimetableTypes.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 03/10/2020.
//

import Foundation

struct Course: Codable {
    let day: String
    let startHour: Int
    let endHour: Int
    let frequency: String
    let room: String
    let group: String
    let type: String
    let name: String
    let teacher: String
    let id: String
    
    var shouldShow: Bool = true
}

typealias Timetable = [Course]

enum TimetableError: Error {
    case groupNotFound
    case groupTimetableNotFound
    case parsingError
}

struct Item: Codable {
    let id: String
    let value: String
}

typealias Year = Item
typealias Group = Item
typealias Semigroup = Item

enum WeekViewType {
    case one, two, both
}
