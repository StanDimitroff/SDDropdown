//
//  SDDropdown.swift
//  Pods
//
//  Created by Stanislav Dimitrov on 3/16/17.
//
//

import UIKit

public class SDDropdown: UIView {

    private let defaultDimColor = UIColor.black.withAlphaComponent(0.5).cgColor

    public var collection: Any! {
        didSet {
            if let sections = collection as? [String: AnyObject] {
                self.sections = sections
            } else if let rows = collection as? [String] {
                self.rows = rows
            }

            setupTableView()
        }
    }

    public var selectionIndexPath: IndexPath?

    fileprivate var presenter: UIViewController?
    fileprivate var rowHeight: CGFloat?
    fileprivate var multiselect: Bool = false
    fileprivate var cellClass: AnyClass?
    fileprivate var targetView: UIView!
    fileprivate var selectedData: [String] = []
    fileprivate var tapGesture: UITapGestureRecognizer?

    public var onSelect: ((String, IndexPath?, IndexPath) -> ())?
    public var onMultiSelect: (([String], IndexPath?) -> ())?

    fileprivate var tableView: UITableView!

    fileprivate var sections: [String: AnyObject] = [:] {
        didSet {

            filteredSections = sections
        }
    }

    fileprivate var filteredSections: [String: AnyObject] = [:]

    fileprivate var rows: [String] = [] {
        didSet {
            rows = rows.sorted {
                (s1, s2) -> Bool in return s1.localizedStandardCompare(s2) == .orderedAscending
            }

            filteredRows = rows
        }
    }

    fileprivate var filteredRows: [String] = []

    lazy var overlayView: UIView = self.makeOverlay()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(collection: Any, targetView: UIView, presenter: UIViewController? = nil, cellClass: AnyClass? = nil, multiselect: Bool? = nil, rowHeight: CGFloat? = nil, selectionIndexPath: IndexPath? = nil) {

        self.targetView         = targetView
        self.presenter          = presenter ?? UIApplication.shared.keyWindow?.rootViewController
        self.cellClass          = cellClass
        self.multiselect        = multiselect ?? false
        self.rowHeight          = rowHeight
        self.selectionIndexPath = selectionIndexPath

        super.init(frame: CGRect(x: presenter!.view.frame.origin.x + 10, y: targetView.frame.maxY + 10, width: presenter!.view.frame.width - 20, height: 300))

        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true

        setCollection(collection)
    }

    private func setCollection(_ collection: Any) {
        self.collection = collection
    }

    private func setupTableView() {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        var tableView = UITableView(frame: frame, style: .plain)
        tableView.allowsMultipleSelection = multiselect ?? false
        if multiselect {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))

            let doneButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: headerView.frame.width - 10, height: headerView.frame.height - 10))
            doneButton.setTitle("Done", for: .normal)
            doneButton.backgroundColor = .purple
            doneButton.layer.cornerRadius = 8
            doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)

            headerView.addSubview(doneButton)
            doneButton.center = headerView.center

            tableView.tableHeaderView = headerView
        }

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dropdownCell")
        tableView.dataSource = self
        tableView.delegate = self

        self.tableView = tableView

        self.addSubview(tableView)

        if let presenter = self.presenter {
            setupOverlay()
            presenter.view.addSubview(self)
        }
    }

    fileprivate func makeOverlay() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }

    fileprivate func setupOverlay() {
        if let overlaySublayers = overlayView.layer.sublayers {
            for layer in overlaySublayers {
                layer.removeFromSuperlayer()
            }
        }

        let overlayPath = UIBezierPath(rect: self.presenter!.view.bounds)
        overlayPath.usesEvenOddFillRule = true

        let convertedFrame = targetView.superview?.convert(targetView.frame, to: overlayView)

        if let cf = convertedFrame {
            let highlightedFrame = cf.insetBy(dx: -5, dy: -5)
            let transparentPath = UIBezierPath(roundedRect: highlightedFrame, cornerRadius: 5)
            overlayPath.append(transparentPath)
        }

        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = defaultDimColor

        overlayView.layer.addSublayer(fillLayer)

        self.presenter?.view.addSubview(overlayView)

        let views = ["overlayView": overlayView]

        self.presenter?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.presenter?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        overlayView.addGestureRecognizer(tapGesture!)
    }

    fileprivate func removeOverlay() {
        overlayView.removeGestureRecognizer(tapGesture!)
        overlayView.removeFromSuperview()
    }

    @objc private func done() {
        dismiss()
        onMultiSelect?(selectedData, selectionIndexPath)
    }

    @objc fileprivate func dismiss() {
        removeFromSuperview()
        removeOverlay()
    }

    public func filter(_ term: String) {
        if !term.isEmpty {
            filteredRows.removeAll(keepingCapacity: false)
            filteredRows = rows.filter { value in
                return value.lowercased().contains(term.lowercased())
            }

            filteredSections.removeAll(keepingCapacity: false)
            sections.forEach { key , value in
                guard let rows = value as? [String] else { return }

                let filteredRows = rows.filter { value in
                    return value.lowercased().contains(term.lowercased())
                }

                filteredSections[key] = filteredRows as AnyObject?
            }
        } else {
            filteredRows = rows
            filteredSections = sections
        }

        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension SDDropdown: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.isEmpty ? 1 : sections.keys.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !sections.isEmpty {
            return Array(sections.keys)[section]
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredSections.isEmpty {
            return Array(filteredSections.values)[section].count
        }

        return filteredRows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item: String = ""

        if !sections.isEmpty {
            let values = Array(filteredSections.values)[indexPath.section] as! [String]
            item = values[indexPath.row]
        } else {
            item = filteredRows[indexPath.row]
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = item

        return cell
    }
}

// MARK: UITableViewDelegate
extension SDDropdown: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight ?? 50
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var value: String = ""

        if !filteredSections.isEmpty {
            let values = Array(filteredSections.values)[indexPath.section] as! [String]
            value = values[indexPath.row]
        } else {
            value = filteredRows[indexPath.row]
        }

        if !multiselect {
            dismiss()
            onSelect?(value, self.selectionIndexPath, indexPath)
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}

