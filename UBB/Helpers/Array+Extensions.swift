import Foundation

extension Array where Element: Hashable {
    var unique: Self {
        Array(self.asSet)
    }
    var asSet: Set<Element> {
        Set(self)
    }
}
