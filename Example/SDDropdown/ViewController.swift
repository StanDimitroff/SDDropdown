//
//  ViewController.swift
//  SDDropdown
//
//  Created by StanDimitroff on 03/16/2017.
//  Copyright (c) 2017 StanDimitroff. All rights reserved.
//

import UIKit
import SDDropdown

class ViewController: UIViewController {

    let users: [User] = [
        User(id: 1, firstName: "Stanislav", lastName: "Dimitrov", gender: "male", age: 30),
        User(id: 2, firstName: "Test", lastName: "Testov", gender: "male", age: 20),
        User(id: 3, firstName: "Testka", lastName: "Testova", gender: "female", age: 21)
    ]

    @IBAction func showDropdown(_ sender: UIButton) {
        let dropdown = SDDropdown(config: nil)

        dropdown.data = users
        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCell else { return }
            cell.valueLabel.text = value
        }

        dropdown.show()

        dropdown.onSelect = { selected, _, ip in
            print(selected)
            print(ip.row)
        }
    }

    @IBAction func showSearch(_ sender: UIButton) {
        let twoSections: [DropdownSection] = [
            DropdownSection("First section", rows: users),
            DropdownSection("Second section", rows: users)
        ]

        let dropdown = SDDropdown(config: nil)

        dropdown.data = twoSections
        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCell else { return }
            cell.valueLabel.text = value
        }

        dropdown.onMultiSelect = { selected, ip in
            print(selected)
        }

        dropdown.show()
    }

    @IBAction func showManySections(_ sender: UIButton) {

        let threeSections: [DropdownSection] = [
            DropdownSection("First section", rows: users),
            DropdownSection("Second section", rows: users),
            DropdownSection("Third section", rows: users)
        ]

        let dropdown = SDDropdown(config: nil)

        dropdown.data = threeSections
        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCell else { return }
            cell.valueLabel.text = value
        }

        dropdown.onMultiSelect = { selected, ip in
            print(selected)
        }

        dropdown.show()
    }
}

