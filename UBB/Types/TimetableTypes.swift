//
//  TimetableTypes.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 03/10/2020.
//

import Foundation

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

enum Day: String, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday
}
