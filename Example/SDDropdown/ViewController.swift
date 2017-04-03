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

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!

    var searchD: SDDropdown!

    let rows = ["Test", "Mest", "Rest"]

    let dict: [String: [String]] = [
        "First section": ["One", "Two"], "Second section": ["First", "Second"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.addTarget(self, action: #selector(textFieldTapped), for: .touchDown)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func textFieldTapped() {
        let dropdown = SDDropdown(collection: dict, targetView: textField, presenter: self, multiselect: true, cellNib: UINib(nibName: "CustomCell", bundle: nil))

        dropdown.configureCell = { ip, value, cell in
            guard let cell = cell as? CustomCell else { return }
            cell.valueLabel.text = value
        }

        dropdown.show()
        searchD = dropdown
    }

    func textFieldDidChange(_ textField: UITextField) {
        searchD.filter(textField.text!)
    }

    @IBAction func showDropdown(_ sender: UIButton) {
        let dropdown = SDDropdown(collection: rows, targetView: button, presenter: self, multiselect: false, cellNib: UINib(nibName: "CustomCell", bundle: nil))

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
}

