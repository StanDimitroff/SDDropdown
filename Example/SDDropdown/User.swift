//
//  User.swift
//  SDDropdown
//
//  Created by Stanislav Dimitrov on 4/11/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import SDDropdown

struct User: Selectable {

    let id: Int
    let firstName: String
    let lastName: String
    let gender: String
    let age: Int

    var title: String {
        return "\(firstName) \(lastName)"
    }

    var filterKey: String {
        return self.title
    }

    var orderKey: String {
        return self.firstName
    }

    public init(id: Int, firstName: String, lastName: String, gender: String, age: Int) {
        self.id        = id
        self.firstName = firstName
        self.lastName  = lastName
        self.gender    = gender
        self.age       = age
    }
}
