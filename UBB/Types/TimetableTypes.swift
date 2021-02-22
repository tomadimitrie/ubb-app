//
//  TimetableTypes.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 03/10/2020.
//

import Foundation

class Item: Codable {
    let id: String
    let value: String
    let index: Int
    
    required init(id: String, value: String, index: Int) {
        self.id = id
        self.value = value
        self.index = index
    }
}

extension Item: Equatable {
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

class Year: Item {}
class Group: Item {}
class Semigroup: Item {
    static var `default`: Self {
        Self(id: "default", value: "default", index: 0)
    }
}

enum WeekViewType {
    case one, two, both
}

enum Day: String, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday
}
