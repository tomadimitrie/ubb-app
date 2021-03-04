import SwiftUI

extension Color {
    var values: ColorValues {
        let array = self.cgColor!.components!.map { Double($0) }
        return ColorValues(
            r: array[0],
            g: array[1],
            b: array[2],
            a: array[3]
        )
    }
    var r: Double {
        self.values.r
    }
    
    var g: Double {
        self.values.g
    }
    
    var b: Double {
        self.values.b
    }
    
    var a: Double {
        self.values.a
    }
    
    var isLight: Bool {
        ((self.r * 299) + (self.g * 587) + (self.b * 114)) / 1000 > 0.5
    }
    
    var isDark: Bool {
        !self.isLight
    }
}
