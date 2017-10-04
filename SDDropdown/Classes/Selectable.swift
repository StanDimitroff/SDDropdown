//
//  Selectable.swift
//  Nimble
//
//  Created by Stanislav Dimitrov on 3.10.17.
//

import Foundation

public protocol Selectable {
    var title: String { get }
    var filterKey: String { get }
    var orderKey: String { get }
    var identifier: String { get }
}

extension Selectable {
    func isEqualTo(_ other: Selectable?) -> Bool {
        guard let rhs = other else { return false }

        return identifier == rhs.identifier
    }
}
