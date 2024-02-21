//
//  BreadcrumbsMenuItem.swift
//
//
//  Created by Nanashi Li on 2023/12/24.
//

import Foundation
import AppKit

final class BreadcrumbsMenuItem: NSMenuItem {
    let fileItem: BreadcrumbItem
    private let tappedOpenFile: (BreadcrumbItem) -> Void

    init(
        fileItem: BreadcrumbItem,
        tappedOpenFile: @escaping (BreadcrumbItem) -> Void
    ) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
        super.init(title: fileItem.fileName, action: #selector(openFile), keyEquivalent: "")

        target = self
        representedObject = fileItem

        // Setup submenu if the item has children
        if fileItem.children != nil {
            let subMenu = NSMenu()
            submenu = subMenu
        }

        // Setup image
        image = NSImage(systemSymbolName: fileItem.systemImage, accessibilityDescription: fileItem.fileName)
        image?.size = NSSize(width: 16, height: 16)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func openFile() {
        tappedOpenFile(fileItem)
    }
}
