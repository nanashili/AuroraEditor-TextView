//
//  File.swift
//  
//
//  Created by Nanashi Li on 2023/12/24.
//

import Foundation
import AppKit

class BreadcrumbsComponentView: NSView {
    private var fileItem: BreadcrumbItem
    private var tappedOpenFile: (BreadcrumbItem) -> Void
    private var imageView: NSImageView!
    private var textView: NSTextField!

    init(fileItem: BreadcrumbItem,
         tappedOpenFile: @escaping (BreadcrumbItem) -> Void) {
        self.fileItem = fileItem
        self.tappedOpenFile = tappedOpenFile
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // ImageView for the file icon
        imageView = NSImageView()
        imageView.image = NSImage(systemSymbolName: image, accessibilityDescription: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        // TextView for the file name
        textView = NSTextField(labelWithString: fileItem.fileName)
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        // Layout constraints
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 12),
            imageView.heightAnchor.constraint(equalToConstant: 12),
            textView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            textView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        ])

        // Set up tap gesture
        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    private var image: String {
        fileItem.parent == nil ? "square.dashed.inset.filled" : fileItem.systemImage
    }

    @objc private func handleTap() {
        if let siblings = fileItem.parent?.children, !siblings.isEmpty {
            let menu = BreadcrumsMenu(fileItems: siblings, tappedOpenFile: tappedOpenFile)
            menu.popUp(positioning: nil, at: frame.origin, in: self)
        }
    }
}
