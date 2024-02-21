//
//  File.swift
//  
//
//  Created by Nanashi Li on 2023/12/21.
//

import Foundation
import AppKit

// Define a simple view controller for the popover content
class SimpleTextViewController: NSViewController {
    override func loadView() {
        self.view = NSView()

        let label = NSTextField(labelWithString: "Hello World")
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
