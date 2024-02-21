//
//  BreadcrumbView.swift
//  
//
//  Created by Nanashi Li on 2023/12/24.
//

import AppKit

class BreadcrumbView: NSView {
    var fileItems: [BreadcrumbItem] = [] {
        didSet {
            buildBreadcrumbs()
        }
    }

    var tappedOpenFile: ((BreadcrumbItem) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        buildBreadcrumbs()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildBreadcrumbs() {
        // Reuse stackView if it already exists
        let stackView: NSStackView
        if let existingStackView = subviews.first(where: { $0 is NSStackView }) as? NSStackView {
            stackView = existingStackView
            stackView.subviews.forEach { $0.removeFromSuperview() } // Clear existing arranged subviews
        } else {
            stackView = NSStackView()
            stackView.orientation = .horizontal
            stackView.spacing = 1.5
            stackView.edgeInsets = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

            addSubview(stackView) // Add the stack view to the view hierarchy if not already added
        }

        // Reuse chevron image view
        let chevronImage = NSImage(systemSymbolName: "chevron.compact.right", accessibilityDescription: nil)
        let chevronImageView = NSImageView(image: chevronImage!)
        chevronImageView.contentTintColor = .secondaryLabelColor

        for (index, fileItem) in fileItems.enumerated() {
            if index > 0 {
                stackView.addArrangedSubview(chevronImageView)
            }
            let breadcrumbComponent = createBreadcrumbComponent(for: fileItem)
            stackView.addArrangedSubview(breadcrumbComponent)
        }

        stackView.wantsLayer = true
        stackView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    private func createBreadcrumbComponent(for fileItem: BreadcrumbItem) -> NSView {
        let breadcrumbComponent = BreadcrumbsComponentView(fileItem: fileItem,
                                                           tappedOpenFile: tappedOpenFile ?? { _ in })
        breadcrumbComponent.translatesAutoresizingMaskIntoConstraints = false
        return breadcrumbComponent
    }

    @objc private func breadcrumbClicked(_ sender: NSButton) {
        let index = sender.tag
        let fileItem = fileItems[index]
        tappedOpenFile?(fileItem)
    }

    func setFileItems(_ newFileItems: [BreadcrumbItem]) {
        self.fileItems = newFileItems
    }

    // Call this method when the fileItem changes
    func fileInfo(_ file: BreadcrumbItem) {
        fileItems = []
        var currentFile: BreadcrumbItem? = file
        while let currentFileLoop = currentFile {
            fileItems.insert(currentFileLoop, at: 0)
            currentFile = currentFileLoop.parent
        }
    }
}
