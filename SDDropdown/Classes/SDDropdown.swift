//
//  SDDropdown.swift
//  SDDropdown
//
//  Created by StanDimitroff on 03/16/2017.
//  Copyright (c) 2017 StanDimitroff. All rights reserved.
//

public protocol Selectable {
    var key: String { get }
}

import UIKit

private let cellReuseIdentifier: String = "dropdownCell"

public final class SDDropdown: UIView {

    private let defaultDimColor = UIColor.black.withAlphaComponent(0.5).cgColor
    private let overlayView = UIView()
    private let tableContainerView = UIView()
    private let searchTextField = UITextField()
    private var cellNib: UINib!
    private var kbFrame: CGRect = .zero

    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate var presenter: UIViewController!
    fileprivate var rowHeight: CGFloat?
    fileprivate var multiselect: Bool!
    fileprivate var searchField: Bool!
    fileprivate var targetView: UIView!
    fileprivate var selectedData: [Selectable] = []
    fileprivate var tapGesture: UITapGestureRecognizer?
    fileprivate var tableView: UITableView = UITableView()

    fileprivate var sections: [String: [Selectable]] = [:] {
        didSet {
            filteredSections = sections
        }
    }

    fileprivate var filteredSections: [String: [Selectable]] = [:]

    fileprivate var rows: [Selectable] = [] {
        didSet {
            rows = rows.sorted {
                (s1, s2) -> Bool in return s1.key.localizedStandardCompare(s2.key) == .orderedAscending
            }

            filteredRows = rows
        }
    }

    fileprivate var filteredRows: [Selectable] = []

    public var collection: Any! {
        didSet {
            if let sections = collection as? [String: [Selectable]] {
                self.sections = sections
            } else if let rows = collection as? [Selectable] {
                self.rows = rows
            }
        }
    }

    public var selectionIndexPath: IndexPath?

    public var configureCell: ((Int, String, SDDropdownCell) -> ())?
    public var onSelect: ((Selectable, IndexPath?, IndexPath) -> ())?
    public var onMultiSelect: (([Selectable], IndexPath?) -> ())?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(collection: Any,
                targetView: UIView,
                cellNib: UINib,
                presenter: UIViewController? = nil,
                multiselect: Bool? = nil,
                searchField: Bool? = nil,
                rowHeight: CGFloat? = nil,
                selectionIndexPath: IndexPath? = nil) {

        self.targetView         = targetView
        self.cellNib            = cellNib
        self.presenter          = presenter ?? UIApplication.shared.keyWindow?.rootViewController!
        self.multiselect        = multiselect ?? false
        self.searchField        = searchField ?? false
        self.rowHeight          = rowHeight
        self.selectionIndexPath = selectionIndexPath

        let viewFrame: CGRect = self.presenter.view.frame
        super.init(frame: viewFrame)

        addKeyboardObservers()
        registerForOrientationChanges()

        setCollection(collection)
    }

    private func setCollection(_ collection: Any) {
        self.collection = collection
    }

    private func setTableContainerView() {
        tableContainerView.frame = CGRect(x: targetView.frame.origin.x,
                                          y: targetView.frame.origin.y,
                                          width: self.frame.width - 20,
                                          height: 0)

        //tableContainerView.layer.cornerRadius = 10
        //tableContainerView.layer.masksToBounds = true

        addSubview(tableContainerView)
        //tableContainerView.center = targetView.center

        setupTableView()
    }

    private func adjustDropdownHeight() {
        var newHeight: CGFloat = tableView.contentSize.height
        UIView.animate(withDuration: 0.35, animations: {
            self.tableContainerView.frame.size.height = newHeight
        })
        
        setNeedsUpdateConstraints()

        if kbFrame != .zero {
            let tableContainerMaxY = tableContainerView.frame.maxY
            let keyboardY = kbFrame.origin.y

            if tableContainerMaxY > keyboardY {
                let delta = abs(tableContainerMaxY - keyboardY) + 8
                 newHeight -= delta
            }
        }

        UIView.animate(withDuration: 0.35, animations: {
            self.tableContainerView.frame.size.height = newHeight
        })
    }

    private func layoutDropdown() {
        if kbFrame != .zero {
            let frame = CGRect(x: tableContainerView.frame.origin.x,
                               y: 20,
                               width: self.frame.width,
                               height: self.frame.height - kbFrame.height)
            let visibleView = UIView(frame: frame)

            var newY: CGFloat = tableContainerView.frame.origin.y
            let tableContainerMaxY = tableContainerView.frame.maxY
            let keyboardY = kbFrame.origin.y

            if tableContainerMaxY > keyboardY {
                let delta = abs(tableContainerMaxY - keyboardY) + 8
                newY -= delta

                if newY < visibleView.frame.origin.y {
                    newY = visibleView.frame.origin.y
                }

                UIView.animate(withDuration: 0.35, animations: {
                    self.tableContainerView.frame.origin.y = newY
                })
            }
        }
    }

    private func setupTableView() {
        tableView.frame = tableContainerView.frame
        tableView.allowsMultipleSelection = multiselect

        tableView.register(cellNib, forCellReuseIdentifier: cellReuseIdentifier)

        if searchField {
            let headerView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: tableContainerView.frame.width,
                                                  height: 35))

            searchTextField.frame = CGRect(x: 0,
                                           y: 0,
                                           width: headerView.frame.width - 100,
                                           height: headerView.frame.height - 10)
            searchTextField.layer.masksToBounds = false
            searchTextField.borderStyle = .none
            searchTextField.layer.borderColor = UIColor.lightGray.cgColor
            searchTextField.layer.borderWidth = 1.0
            searchTextField.layer.cornerRadius = 3.0

            searchTextField.layer.shadowColor = UIColor.black.cgColor
            searchTextField.layer.shadowOffset = CGSize(width: 0, height: 1)
            searchTextField.layer.shadowRadius = 2.0

            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: searchTextField.frame.size.height))
            searchTextField.leftView = leftView
            searchTextField.leftViewMode = .always

            searchTextField.addTarget(self, action: #selector(setFieldActive(_:)), for: .editingDidBegin)
            searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            headerView.addSubview(searchTextField)
            searchTextField.center = headerView.center
            tableView.tableHeaderView = headerView
        }
        
        if multiselect {
            let footerView = UIView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: tableContainerView.frame.width,
                                                  height: 40))


            let doneButton: UIButton = UIButton(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: footerView.frame.width - 10,
                                                              height: footerView.frame.height - 10))
            doneButton.setTitle("Done", for: .normal)
            doneButton.backgroundColor =  #colorLiteral(red: 0.3764705882, green: 0.1568627451, blue: 0.3215686275, alpha: 1)
            //doneButton.layer.cornerRadius = 10
            doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)

            footerView.addSubview(doneButton)
            doneButton.center = footerView.center

            tableView.tableFooterView = footerView
        }

        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self

        tableContainerView.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableContainerView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[tableView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["tableView": tableView]))
        tableContainerView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[tableView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["tableView": tableView]))
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

    private func registerForOrientationChanges() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
    }

    private func unregisterFromOrientationChanges() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIDeviceOrientationDidChange,
                                                  object: nil)
    }

    func orientationChanged() {
        setNeedsDisplay()
    }
    
    @objc
    private func keyboardDidShow(_ notification: Notification) {
        kbFrame = keyboardFrame(notification)
        layoutDropdown()
        adjustDropdownHeight()
    }

    @objc
    private func keyboardDidHide(_ notification: Notification) {
        kbFrame = .zero
        adjustDropdownHeight()
        setFieldInactive()

        UIView.animate(withDuration: 0.35, animations: {
            self.tableContainerView.center = self.center
        })
    }

    @objc
    private func setFieldActive(_ textField: UITextField) {
        textField.layer.borderColor = #colorLiteral(red: 0.3764705882, green: 0.1568627451, blue: 0.3215686275, alpha: 1).cgColor
        textField.layer.borderWidth = 2.0
        textField.layer.shadowOpacity = 1.0
    }

    @objc
    private func setFieldInactive() {
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.borderWidth = 1.0
        searchTextField.layer.shadowOpacity = 0.0
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        filter(textField.text!)
    }

    @objc
    private func done() {
        dismiss()
        onMultiSelect?(selectedData, selectionIndexPath)
    }

    fileprivate func setupOverlay() {
        overlayView.frame = self.frame
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        if let overlaySublayers = overlayView.layer.sublayers {
            for layer in overlaySublayers {
                layer.removeFromSuperlayer()
            }
        }

        let overlayPath = UIBezierPath(rect: self.bounds)
        overlayPath.usesEvenOddFillRule = true

        //let convertedFrame = targetView.superview?.convert(targetView.frame, to: overlayView)

//        if let cf = convertedFrame {
//            let highlightedFrame = cf.insetBy(dx: -5, dy: -5)
//            let transparentPath = UIBezierPath(roundedRect: highlightedFrame, cornerRadius: 5)
//            overlayPath.append(transparentPath)
//        }

        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = defaultDimColor

        overlayView.layer.addSublayer(fillLayer)

        addSubview(overlayView)

        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[overlayView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["overlayView": overlayView]))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[overlayView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["overlayView": overlayView]))

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        overlayView.addGestureRecognizer(tapGesture!)

        setTableContainerView()
    }

    fileprivate func removeOverlay() {
        overlayView.removeGestureRecognizer(tapGesture!)
        overlayView.removeFromSuperview()
    }

    fileprivate func keyboardFrame(_ notification: Notification) -> CGRect {
        let userInfo = notification.userInfo!

        return (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    }

    fileprivate func hideKeyboard() {
        presenter.view.endEditing(true)
    }

    fileprivate func reloadTable() {
        tableView.reloadData()
    }

    @objc
    fileprivate func dismiss() {
        UIView.animate(withDuration: 0.35, animations: {
            //self.tableContainerView.frame.origin.y = self.targetView.frame.maxY + 10
            self.tableContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { finished in
            UIView.animate(withDuration: 0.35) {
                self.removeFromSuperview()
                self.removeOverlay()
                self.hideKeyboard()
            }
        })
    }

    /// Show dropdown with animation
    public func show() {
        if let presenter = self.presenter {
            setupOverlay()

            UIView.animate(withDuration: 0.35, animations: {
                self.tableContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { finished in
                UIView.animate(withDuration: 0.35) {
                    self.tableContainerView.transform = CGAffineTransform.identity
                    presenter.view.addSubview(self)
                    self.adjustDropdownHeight()
                    self.tableContainerView.center = self.center
                }
            })
        }
    }

    /// Hide dropdown
    public func hide() {
        dismiss()
    }

    /// Filter by term
    ///
    /// - Parameter term: the term for filtering
    private func filter(_ term: String) {
        if !term.isEmpty {
            filteredRows.removeAll(keepingCapacity: false)
            filteredRows = rows.filter { value in
                return value.key.lowercased().contains(term.lowercased())
            }

            filteredSections.removeAll(keepingCapacity: false)
            sections.forEach { key, value in

                let filteredRows = value.filter { value in
                    return value.key.lowercased().contains(term.lowercased())
                }

                filteredSections[key] = filteredRows
            }
        } else {
            filteredRows = rows
            filteredSections = sections
        }

        reloadTable()
        adjustDropdownHeight()
    }

    deinit {
        removeKeyboardObservers()
        unregisterFromOrientationChanges()
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
        var value: String = ""

        if !sections.isEmpty {
            value = Array(filteredSections.values)[indexPath.section][indexPath.row].key
        } else {
            value = filteredRows[indexPath.row].key
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier,
                                                 for: indexPath) as! SDDropdownCell
        cell.selectionStyle = .none

        configureCell?(indexPath.row, value, cell)

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
        hideKeyboard()

        var selected: Selectable!
        if !filteredSections.isEmpty {
            selected = Array(filteredSections.values)[indexPath.section][indexPath.row]
        } else {
            selected = filteredRows[indexPath.row]
        }

        if !multiselect {
            dismiss()
            onSelect?(selected, self.selectionIndexPath, indexPath)
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            selectedData.append(selected)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        hideKeyboard()

        var selected: Selectable!
        if !filteredSections.isEmpty {
            selected = Array(filteredSections.values)[indexPath.section][indexPath.row]
        } else {
            selected = filteredRows[indexPath.row]
        }

        let deselectedIndex = selectedData.index(where: { $0.key == selected.key })
        guard let index = deselectedIndex else { return }

        selectedData.remove(at: index)

        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
}

