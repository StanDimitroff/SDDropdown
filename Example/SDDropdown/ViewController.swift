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
        let dropdown = SDDropdown()

        dropdown.data = users

        dropdown.onSelect = { selected, _, ip in
            print(selected)
            print(ip.row)
        }

        dropdown.show()
    }

    @IBAction func showSearch(_ sender: UIButton) {
        let twoSections: [DropdownSection] = [
            DropdownSection("First section", rows: users),
            DropdownSection("Second section", rows: users)
        ]

        let dropdown = SDDropdown(config: Configuration(
            presenter: self,
            cellNib: UINib(nibName: "CustomCellNib", bundle: nil)))

        dropdown.data = twoSections

        dropdown.configureCell = { _, value, cell in
            guard let cell = cell as? CustomCellNib else { return }
            cell.customView.backgroundColor = .orange
            cell.customLabel.text = value
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

        let dropdown = SDDropdown(config: Configuration(
            presenter: self,
            multiselect: true,
            searchField: true,
            cellClass: CustomCellClass.self))

        dropdown.data = threeSections
        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCellClass else { return }
            cell.textLabel?.text = value
        }

        dropdown.onMultiSelect = { selected, ip in
            print(selected)
        }

        dropdown.show()
    }
}

