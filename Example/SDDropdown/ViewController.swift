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

    let rows = ["Test", "Mest", "Rest"]

    let twoSections: [String: [String]] = [
        "First section": ["One", "Two"],
        "Second section": ["First", "Second"]
    ]

    let threeSections: [String: [String]] = [
        "First section": ["One", "Two"],
        "Second section": ["First", "Second"],
        "Third section": ["Test", "Test1", "Test2"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showDropdown(_ sender: UIButton) {
        let dropdown = SDDropdown(collection: rows, targetView: sender, presenter: self, multiselect: false, searchField: false, cellNib: UINib(nibName: "CustomCell", bundle: nil))

        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCell else { return }
            cell.valueLabel.text = value
        }

        dropdown.show()

        dropdown.onSelect = { value, _, ip in
            print(value)
            print(ip.row)
        }
    }

    @IBAction func showSearch(_ sender: UIButton) {
        let dropdown = SDDropdown(collection: twoSections, targetView: sender, presenter: self, multiselect: true, searchField: true, cellNib: UINib(nibName: "CustomCell", bundle: nil))

        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCell else { return }
            cell.valueLabel.text = value
        }

        dropdown.show()
    }

    @IBAction func showManySections(_ sender: UIButton) {
        let dropdown = SDDropdown(collection: threeSections, targetView: sender, presenter: self, multiselect: true, searchField: true, cellNib: UINib(nibName: "CustomCell", bundle: nil))

        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCell else { return }
            cell.valueLabel.text = value
        }

        dropdown.show()
    }
}

