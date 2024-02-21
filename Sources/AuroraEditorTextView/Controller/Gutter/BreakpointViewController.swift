//
//  BreakpointViewController.swift
//
//
//  Created by Nanashi Li on 2023/12/21.
//

import Foundation
import AppKit

class BreakpointViewController: NSViewController {
    private var nameTextField: NSTextField!
    private var conditionTextField: NSTextField!
    private var ignoreStepper: NSStepper!
    private var actionButton: NSPopUpButton!
    private var automaticallyContinueCheckbox: NSButton!

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 160))
        setupUIComponents()
    }

    private func setupUIComponents() {
        // Name Text Field
        nameTextField = NSTextField(frame: NSRect(x: 20, y: 120, width: 260, height: 20))
        nameTextField.placeholderString = "Name"
        view.addSubview(nameTextField)

        // Condition Text Field
        conditionTextField = NSTextField(frame: NSRect(x: 20, y: 90, width: 260, height: 20))
        conditionTextField.placeholderString = "Condition"
        view.addSubview(conditionTextField)

        // Ignore Stepper
        ignoreStepper = NSStepper(frame: NSRect(x: 250, y: 60, width: 20, height: 20))
        ignoreStepper.valueWraps = false
        ignoreStepper.minValue = 0
        ignoreStepper.maxValue = 100
        ignoreStepper.increment = 1
        view.addSubview(ignoreStepper)

        // Ignore Label
        let ignoreLabel = NSTextField(frame: NSRect(x: 20, y: 60, width: 200, height: 20))
        ignoreLabel.stringValue = "Ignore"
        ignoreLabel.isBezeled = false
        ignoreLabel.isEditable = false
        ignoreLabel.backgroundColor = .clear
        view.addSubview(ignoreLabel)

        // Action Button (Pop Up Button)
        actionButton = NSPopUpButton(frame: NSRect(x: 20, y: 30, width: 260, height: 20), pullsDown: false)
        actionButton.addItems(withTitles: ["Add Action", "Log Message", "Play Sound", "Capture GPU Frame"])
        view.addSubview(actionButton)

        // Automatically Continue Checkbox
        automaticallyContinueCheckbox = NSButton(frame: NSRect(x: 20, y: 0, width: 260, height: 20))
        automaticallyContinueCheckbox.setButtonType(.switch)
        automaticallyContinueCheckbox.title = "Automatically continue after evaluating actions"
        view.addSubview(automaticallyContinueCheckbox)
    }

    // Add additional methods to handle actions and logic
}
