import Foundation
import Collections

extension Array where Element: Hashable {
    var unique: Self {
        Array(self.asSet)
    }

    var asSet: Set<Element> {
        Set(self)
    }
}

extension Array {
    func once(_ execute: () -> Void) -> Self {
        execute()
        return self
    }

    func grouped<T>(by keyPath: KeyPath<Element, T>) -> OrderedDictionary<T, Self> {
        reduce(OrderedDictionary<T, Self>(), {
            var previous = $0
            previous[$1[keyPath: keyPath]] = (previous[$1[keyPath: keyPath]] ?? []) + [$1]
            return previous
        })
    }
}

extension Slice {
    func once(_ execute: () -> Void) -> Self {
        execute()
        return self
    }
}
