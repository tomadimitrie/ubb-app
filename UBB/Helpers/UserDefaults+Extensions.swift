import Foundation
import SwiftUI

struct ColorValues: Codable {
    let r: Double
    let g: Double
    let b: Double
    let a: Double
}

extension UserDefaults {
    func color(forKey key: String) -> Color? {
        if
            let data = UserDefaults.standard.object(forKey: key) as? Data,
            let values = try? JSONDecoder().decode(ColorValues.self, from: data)
        {
            return Color(.sRGB, red: values.r, green: values.g, blue: values.b, opacity: values.a)
        }
        return nil
    }

    func set(_ color: Color, forKey key: String) {
        let encoded = try! JSONEncoder().encode(color.values)
        UserDefaults.standard.set(
            encoded,
            forKey: key
        )
    }
}
