//
// Created by Dimitrie-Toma Furdui on 20.02.2022.
//

import SwiftSoup

extension Elements {
    func once(_ execute: () -> Void) -> Self {
        execute()
        return self
    }
}

extension Element {
    func once(_ execute: () -> Void) -> Self {
        execute()
        return self
    }
}
