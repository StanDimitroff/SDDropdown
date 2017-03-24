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

        textField.addTarget(self, action: #selector(test), for: .touchDown)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    func test() {
        let dropdown = SDDropdown(collection: dict, targetView: textField, presenter: self, multiselect: true)
        searchD = dropdown
        
    }

    func textFieldDidChange(_ textField: UITextField) {
        searchD.filter(textField.text!)
    }

    @IBAction func showDropdown(_ sender: UIButton) {
        let dropdown = SDDropdown(collection: dict, targetView: button, presenter: self, multiselect: true)

        dropdown.onSelect = { val, _, ip in
            print(val)
            print(ip.row)
        }
    }
}

