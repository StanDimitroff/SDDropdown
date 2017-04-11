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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showDropdown(_ sender: UIButton) {
        let dropdown = SDDropdown(collection: users, targetView: sender, cellNib: UINib(nibName: "CustomCell", bundle: nil), presenter: self)

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
        let twoSections: [String: [User]] = [
            "First section": users,
            "Second section": users
        ]

        let dropdown = SDDropdown(collection: twoSections, targetView: sender, cellNib: UINib(nibName: "CustomCell", bundle: nil), presenter: self, multiselect: true, searchField: true)

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

        let threeSections: [String: [User]] = [
            "First section": users,
            "Second section": users,
            "Third section": users
        ]

        let dropdown = SDDropdown(collection: threeSections, targetView: sender, cellNib: UINib(nibName: "CustomCell", bundle: nil), presenter: self, multiselect: true, searchField: true)

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

