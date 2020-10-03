//
//  UserDefault.swift
//  UBB
//
//  Created by Dimitrie-Toma Furdui on 03/10/2020.
//

import Foundation
import Combine

protocol PublishedWrapper: class {
    var objectWillChange: ObservableObjectPublisher? { get set }
}

@propertyWrapper
class UserDefault<Value: Codable>: PublishedWrapper {
    let initialValue: Value?
    let key: String
    weak var objectWillChange: ObservableObjectPublisher?

    init(wrappedValue: Value?, _ key: String) {
        self.key = key
        self.initialValue = wrappedValue
    }

    var wrappedValue: Value? {
        get {
            let value = UserDefaults.standard.data(forKey: self.key)
            if let value = value {
                return try! PropertyListDecoder().decode(Value.self, from: value)
            } else {
                return self.initialValue
            }
        }
        set {
            self.objectWillChange?.send()
            if let newValue = newValue {
                UserDefaults.standard.set(try! PropertyListEncoder().encode(newValue), forKey: self.key)
            } else {
                UserDefaults.standard.removeObject(forKey: self.key)
            }
        }
    }
}
