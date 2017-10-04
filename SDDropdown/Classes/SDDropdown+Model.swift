//
//  SDDropdown+Model.swift
//  Pods
//
//  Created by Stanislav Dimitrov on 8/7/17.
//
//

import Foundation

typealias DropdownRow = Selectable

public struct DropdownSection {
    let title: String
    let rows: [DropdownRow]

    public init(_ title: String, rows: [Selectable]) {
        self.title = title
        self.rows  = rows
    }
}

extension SDDropdown {

    final class Model {

        // MARK: - Properties
        private var collection: Any
        
        private var sections: [DropdownSection]         = []
        private var rows: [DropdownRow]                 = []

        private var filteredSections: [DropdownSection] = []
        private var filteredRows: [DropdownRow]         = []

        var preSelectedData: [DropdownRow]              = []
        var selectedData: [DropdownRow]                 = []

        init(_ collection: Any) {
            self.collection = collection

            setCollection()
        }

        // MARK: - Internal API
        var numberOfSections: Int {
            return sections.isEmpty ? 1 : sections.count
        }

        func numberOfRows(inSection section: Int) -> Int {
            return !filteredSections.isEmpty
                ? filteredSections[section].rows.count
                : filteredRows.count
        }

        func titleForHeader(inSection section: Int) -> String? {
            return !filteredSections.isEmpty
                ? filteredSections[section].title
                : nil
        }

        func rowAtIndexPath(indexPath: IndexPath) -> DropdownRow {
            return !filteredSections.isEmpty
                ? filteredSections[indexPath.section].rows[indexPath.row]
                : filteredRows[indexPath.row]
        }

        func addSelected(withIndexPath indexPath: IndexPath) {
            let selected = rowAtIndexPath(indexPath: indexPath)
            selectedData.append(selected)
        }

        func removeSelected(atIndexPath indexPath: IndexPath) {
            let selected = rowAtIndexPath(indexPath: indexPath)

            let deselectedIndex = selectedData
                .index(where: { $0.identifier == selected.identifier })
            guard let index = deselectedIndex else { return }

            selectedData.remove(at: index)
        }

        // MARK: - Private API
        private func setCollection() {
            if let sections = collection as? [DropdownSection] {
                self.sections = sections
                filteredSections = sections
            } else if let rows = collection as? [DropdownRow] {
                self.rows = rows
                filteredRows = rows
            } else {
                fatalError(Errors.unsupportedType, file: #file, line: #line)
            }
        }

        /// Append previously selected data
        ///
        /// - Parameter data: the data which will be added
        func addPreselectedData(_ data: [Selectable]?) {
            guard let preSelected = data else { return }

            preSelectedData = preSelected

            selectedData.append(contentsOf: preSelected)
        }

        /// Filter by term
        ///
        /// - Parameter term: the term for filtering
        func filter(_ term: String) {
//            if !term.isEmpty {
//                filteredRows.removeAll(keepingCapacity: false)
//                filteredRows = rows.filter { value in
//                    return value.filterKey.lowercased().contains(term.lowercased())
//                }
//
//                filteredSections.removeAll(keepingCapacity: false)
//                sections.forEach { key, value in
//
//                    let filteredRows = value.filter { value in
//                        return value.filterKey.lowercased().contains(term.lowercased())
//                    }
//
//                    filteredSections[key] = filteredRows
//                }
//            } else {
//                filteredRows     = rows
//                filteredSections = sections
//            }
        }
    }
}
