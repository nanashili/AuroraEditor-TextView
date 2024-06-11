//
//  File.swift
//  
//
//  Created by Nanashi Li on 2023/12/19.
//

import Foundation
import Cocoa

public class FindReplaceViewController: NSViewController {
    let findTextField = NSTextField()
    let replaceTextField = NSTextField()
    let nextButton = NSButton(title: "Next", target: FindReplaceViewController.self, action: #selector(nextButtonClicked(_:)))
    let previousButton = NSButton(title: "Previous", target: FindReplaceViewController.self, action: #selector(previousButtonClicked(_:)))
    let replaceButton = NSButton(title: "Replace", target: FindReplaceViewController.self, action: #selector(replaceButtonClicked(_:)))
    let replaceAllButton = NSButton(title: "Replace All", target: FindReplaceViewController.self, action: #selector(replaceAllButtonClicked(_:)))
    let doneButton = NSButton(title: "Done", target: FindReplaceViewController.self, action: #selector(doneButtonClicked(_:)))
    let matchCaseCheck = NSButton(checkboxWithTitle: "Match Case", target: nil, action: nil)
    let containsCheck = NSButton(checkboxWithTitle: "Contains", target: nil, action: nil)

    public override func loadView() {
        self.view = NSView()
        setupFindReplaceUI()
    }

    private func setupFindReplaceUI() {
        // Add subviews
        view.addSubview(findTextField)
        view.addSubview(replaceTextField)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        view.addSubview(replaceButton)
        view.addSubview(replaceAllButton)
        view.addSubview(doneButton)
        view.addSubview(matchCaseCheck)
        view.addSubview(containsCheck)

        // Configure the UI elements
        findTextField.placeholderString = "Find"
        replaceTextField.placeholderString = "Replace With"

        // Layout the views manually (for simplicity in this example)
        // In a production app, you would use Auto Layout constraints
        findTextField.frame = CGRect(x: 20, y: 120, width: 200, height: 24)
        replaceTextField.frame = CGRect(x: 20, y: 80, width: 200, height: 24)
        nextButton.frame = CGRect(x: 230, y: 120, width: 80, height: 24)
        previousButton.frame = CGRect(x: 320, y: 120, width: 80, height: 24)
        replaceButton.frame = CGRect(x: 230, y: 80, width: 80, height: 24)
        replaceAllButton.frame = CGRect(x: 320, y: 80, width: 80, height: 24)
        doneButton.frame = CGRect(x: 320, y: 40, width: 80, height: 24)
        matchCaseCheck.frame = CGRect(x: 20, y: 40, width: 130, height: 24)
        containsCheck.frame = CGRect(x: 150, y: 40, width: 130, height: 24)
    }

    @objc func nextButtonClicked(_ sender: NSButton) {
        // Implement the action to find the next occurrence.
    }

    @objc func previousButtonClicked(_ sender: NSButton) {
        // Implement the action to find the previous occurrence.
    }

    @objc func replaceButtonClicked(_ sender: NSButton) {
        // Implement the action to replace the current occurrence.
    }

    @objc func replaceAllButtonClicked(_ sender: NSButton) {
        // Implement the action to replace all occurrences.
    }

    @objc func doneButtonClicked(_ sender: NSButton) {
        // Dismiss the find and replace UI.
        self.view.window?.close()
    }
}
