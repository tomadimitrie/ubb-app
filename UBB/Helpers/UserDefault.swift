import Foundation
import Combine

@propertyWrapper
class UserDefault<Value: Codable> {
    let initialValue: Value?
    let key: String

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
            if let newValue = newValue {
                UserDefaults.standard.set(try! PropertyListEncoder().encode(newValue), forKey: self.key)
            } else {
                UserDefaults.standard.removeObject(forKey: self.key)
            }
        }
    }
}
