//
//  Configuration.swift
//  Pods
//
//  Created by Stanislav Dimitrov on 8/7/17.
//
//

import UIKit

public final class Configuration {

    // MARK: - Properties
    let cellReuseIdentifier: String = "SDDropdownCell"

    private let targetView: UIView?
    let dimColor: UIColor
    let presenter: UIViewController!

    let multiselect: Bool
    let rowHeight: CGFloat
    let searchField: Bool
    let cellNib: UINib?
    let cellClass: AnyClass?
    let selectionIndexPath: IndexPath?

    var anchorView: UIView {
        return targetView ?? presenter.view
    }

    /// Config Initializer
    ///
    /// - Parameters:
    ///   - presenter: UIViewController instance responsible for presenting the view
    ///   - targetView: targetView description
    ///   - multiselect: multiselect description
    ///   - searchField: searchField description
    ///   - rowHeight: rowHeight description
    ///   - dimColor: dimColor description
    ///   - cellNib: the provided UINib
    ///   - cellClass: the provided UITableViewCell class
    ///   - selectionIndexPath: the IndexPath which the dropdown is presented from
    public init(
        presenter: UIViewController? = nil,
        targetView: UIView? = nil,
        multiselect: Bool? = nil,
        searchField: Bool? = nil,
        rowHeight: CGFloat? = nil,
        dimColor: UIColor? = nil,
        cellNib: UINib? = nil,
        cellClass: AnyClass? = nil,
        selectionIndexPath: IndexPath? = nil) {

        self.presenter   = presenter ?? Defaults.presenter
        self.targetView  = targetView
        self.multiselect = multiselect ?? Defaults.hasMultiselect
        self.searchField = searchField ?? Defaults.hasSearchField
        self.rowHeight   = rowHeight ?? Defaults.rowHeight
        self.dimColor    = dimColor ?? Defaults.dimColor
        self.cellNib     = cellNib ?? Defaults.cellNib
        self.cellClass    = cellClass ?? Defaults.cellClass
        self.selectionIndexPath = selectionIndexPath
    }

    /// Default options configuration
    static var defaultConfig: Configuration {

        return Configuration(
            presenter: Defaults.presenter,
            targetView: nil,
            multiselect: Defaults.hasMultiselect,
            searchField: Defaults.hasMultiselect,
            rowHeight: Defaults.rowHeight,
            dimColor: Defaults.dimColor,
            cellNib: Defaults.cellNib,
            cellClass: Defaults.cellClass,
            selectionIndexPath: nil)
    }
}

extension Configuration {
    enum Defaults {
        static let presenter            = UIApplication.shared.keyWindow?.rootViewController!
        static let hasMultiselect: Bool = false
        static let hasSearchField: Bool = false
        static let rowHeight: CGFloat   = 50
        static let dimColor: UIColor    = UIColor.black.withAlphaComponent(0.5)
        static let cellNib: UINib?       = nil
        static let cellClass: AnyClass? = UITableViewCell.self
    }
}
