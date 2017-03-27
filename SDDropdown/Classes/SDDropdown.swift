//
//  SDDropdown.swift
//  Pods
//
//  Created by StanDimitroff on 03/16/2017.
//  Copyright (c) 2017 StanDimitroff. All rights reserved.
//

import UIKit

public class SDDropdown: UIView {

    private let defaultDimColor = UIColor.black.withAlphaComponent(0.5).cgColor
    private lazy var overlayView: UIView = self.makeOverlay()

    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate var presenter: UIViewController?
    fileprivate var rowHeight: CGFloat?
    fileprivate var multiselect: Bool = false
    fileprivate var targetView: UIView!
    fileprivate var selectedData: [String] = []
    fileprivate var tapGesture: UITapGestureRecognizer?
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

    public var onSelect: ((String, IndexPath?, IndexPath) -> ())?
    public var onMultiSelect: (([String], IndexPath?) -> ())?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(collection: Any,
                targetView: UIView,
                presenter: UIViewController? = nil,
                multiselect: Bool? = nil,
                rowHeight: CGFloat? = nil,
                selectionIndexPath: IndexPath? = nil) {

        self.targetView         = targetView
        self.presenter          = presenter ?? UIApplication.shared.keyWindow?.rootViewController
        self.multiselect        = multiselect ?? false
        self.rowHeight          = rowHeight
        self.selectionIndexPath = selectionIndexPath

        let viewFrame: CGRect = CGRect(x: presenter!.view.frame.origin.x + 10,
                                       y: targetView.frame.maxY + 10,
                                       width: presenter!.view.frame.width - 20,
                                       height: 300)
        super.init(frame: viewFrame)

        self.layer.cornerRadius = 10
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
            let headerView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: self.frame.width,
                                                  height: 40))

            let doneButton: UIButton = UIButton(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: headerView.frame.width - 10,
                                                              height: headerView.frame.height - 10))
            doneButton.setTitle("Done", for: .normal)
            doneButton.backgroundColor = .purple
            doneButton.layer.cornerRadius = 10
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

        addKeyboardObservers()

        if let presenter = self.presenter {
            setupOverlay()

            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { finished in
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform.identity
                     presenter.view.addSubview(self)
                }
            })
        }
    }

    private func addKeyboardObservers() {
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardDidShow(_:)),
                                       name: NSNotification.Name.UIKeyboardDidShow,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardDidHide(_:)),
                                       name: NSNotification.Name.UIKeyboardDidHide,
                                       object: nil)
    }

    private func removeKeyboardObservers() {
        notificationCenter.removeObserver(self,
                                          name: NSNotification.Name.UIKeyboardDidShow,
                                          object: nil)
        notificationCenter.removeObserver(self,
                                          name: NSNotification.Name.UIKeyboardDidHide,
                                          object: nil)
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

        self.presenter?.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[overlayView]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.presenter?.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[overlayView]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        overlayView.addGestureRecognizer(tapGesture!)
    }

    fileprivate func removeOverlay() {
        overlayView.removeGestureRecognizer(tapGesture!)
        overlayView.removeFromSuperview()
    }

    fileprivate func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo!

        return (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
    }

    @objc
    private func keyboardDidShow(_ notification: Notification) {
        //self.setNeedsUpdateConstraints()

        let keyboardHeight = self.keyboardHeight(notification)
        let frame = self.frame
        let height =  keyboardHeight - self.frame.height
        //self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height - height)

        // TODO: resize view frame here
    }

    @objc
    private func keyboardDidHide(_ notification: Notification) {
        self.setNeedsUpdateConstraints()
        // TODO: resize view frame here
    }

    @objc
    private func done() {
        dismiss()
        onMultiSelect?(selectedData, selectionIndexPath)
    }

    @objc
    fileprivate func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { finished in
            UIView.animate(withDuration: 0.2) {
                self.removeFromSuperview()
                self.removeOverlay()
                self.presenter!.view.endEditing(true)
            }
        })
    }

    public func show() {

    }

    public func hide() {
        dismiss()
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

    deinit {
        removeKeyboardObservers()
    }
}

// MARK: UITableViewDataSource
extension SDDropdown: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.isEmpty ? 1 : sections.keys.count
    }

    public func tableView(_ tableView: UITableView,
                          titleForHeaderInSection section: Int) -> String? {
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

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item: String = ""

        if !sections.isEmpty {
            if let values = Array(filteredSections.values)[indexPath.section] as? [String] {
                item = values[indexPath.row]
            }
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
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
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

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO: resize view frame here
        presenter?.view.endEditing(true)
    }
}

