import Foundation
import Combine
import SwiftUI

@propertyWrapper
class UserDefault<Value: Codable> {
    let initialValue: Value?
    let key: String

    init(wrappedValue: Value? = nil, _ key: String) {
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
            if let newValue = newValue {
                UserDefaults.standard.set(try! PropertyListEncoder().encode(newValue), forKey: self.key)
            } else {
                UserDefaults.standard.removeObject(forKey: self.key)
            }
        }
    }
}

@propertyWrapper
class UserDefaultColor {
    let initialValue: Color?
    let key: String

    init(wrappedValue: Color? = nil, _ key: String) {
        self.key = key
        self.initialValue = wrappedValue
    }

    var wrappedValue: Color? {
        get {
            UserDefaults.standard.color(forKey: self.key) ?? self.initialValue
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: self.key)
            } else {
                UserDefaults.standard.removeObject(forKey: self.key)
            }
        }
    }
}
