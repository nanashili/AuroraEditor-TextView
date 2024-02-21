//
//  BreadcrumsMenu.swift
//
//
//  Created by Nanashi Li on 2023/12/24.
//

import Foundation
import AppKit

final class BreadcrumsMenu: NSMenu, NSMenuDelegate {
    private let fileItems: [BreadcrumbItem]
    private let tappedOpenFile: (BreadcrumbItem) -> Void

    public init(
        fileItems: [BreadcrumbItem],
        tappedOpenFile: @escaping (BreadcrumbItem) -> Void
    ) {
        self.fileItems = fileItems
        self.tappedOpenFile = tappedOpenFile
        super.init(title: "")
        delegate = self
        fileItems.forEach { item in
            let menuItem = BreadcrumbsMenuItem(
                fileItem: item,
                tappedOpenFile: tappedOpenFile
            )
            self.addItem(menuItem)
        }
        autoenablesItems = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let highlightedItem = item as? BreadcrumbsMenuItem {
            highlightedItem.submenu = generateSubmenu(highlightedItem.fileItem)
        }
    }

    private func generateSubmenu(_ fileItem: BreadcrumbItem) -> NSMenu? {
        guard let children = fileItem.children, !children.isEmpty else { return nil }

        let submenu = BreadcrumsMenu(fileItems: children, tappedOpenFile: tappedOpenFile)
        return submenu
    }
}
