import Foundation
import UIKit

extension UserDefaults {
    func color(forKey key: String) -> UIColor? {
        if let data = self.data(forKey: key) {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        }
        return nil
    }

    func set(_ value: UIColor, forKey key: String) {
        try? self.set(
            NSKeyedArchiver.archivedData(
                withRootObject: value,
                requiringSecureCoding: false
            ),
            forKey: key
        )
    }
}
