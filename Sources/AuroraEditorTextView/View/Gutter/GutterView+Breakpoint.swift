//
//  GutterView+Breakpoint.swift
//  
//
//  Created by Nanashi Li on 2023/12/21.
//

import Foundation
import AppKit

/// An extension of `GutterView` that provides mouse interaction functionalities.
///
/// The extension enables the `GutterView` to respond to mouse down events, which includes
/// detecting double-clicks to show a popover for setting breakpoints, toggling line number
/// selection on single clicks, and showing a context menu on right-clicks.
extension GutterView {

    /// Handles mouse down events within the gutter view.
    /// - Parameter event: The `NSEvent` representing the mouse down action.
    ///
    /// This method checks if the mouse down event is within the bounds of any line number.
    /// On a single click, it toggles the selection state of the line number. On a double-click,
    /// it presents a popover to configure breakpoints for that line number.
    public func handleBreakpointMouseDown(with event: NSEvent) {
        let location = self.convert(event.locationInWindow, from: nil)
        for (lineNumber, textPosition) in lineNumberPositions {
            let detectionArea = CGRect(x: textPosition.x, y: textPosition.y - font.ascender, width: maxWidth, height: font.ascender - font.descender)

            if detectionArea.contains(location) {
                if event.clickCount == 2 {
                    // Detected a double-click on a line number.
                    showBreakpointPopover(at: lineNumber, rect: detectionArea)
                    return
                }

                // Toggle the selection state for the line number.
                if clickedLineNumbers.contains(lineNumber) {
                    clickedLineNumbers.remove(lineNumber)
                } else {
                    clickedLineNumbers.insert(lineNumber)
                }
                self.needsDisplay = true
                return
            }
        }
    }

    /// Handles right mouse down events within the gutter view.
    /// - Parameter event: The `NSEvent` representing the right mouse down action.
    ///
    /// This method checks if the right mouse down event is within the bounds of a selected line number.
    /// If so, it presents a context menu with options related to breakpoint management.
    override public func rightMouseDown(with event: NSEvent) {
        let location = self.convert(event.locationInWindow, from: nil)
        for (lineNumber, textPosition) in lineNumberPositions {
            let detectionArea = CGRect(x: textPosition.x, y: textPosition.y - font.ascender, width: maxWidth, height: font.lineHeight)

            if detectionArea.contains(location) && clickedLineNumbers.contains(lineNumber) {
                // Detected a right-click on a selected line number.
                showContextMenu(for: lineNumber, at: location, with: event)
                return
            }
        }

        super.rightMouseDown(with: event)
    }

    /// Shows a context menu for a given line number.
    /// - Parameters:
    ///   - lineNumber: The line number for which the context menu should be shown.
    ///   - point: The location where the context menu should be anchored.
    ///   - event: The `NSEvent` representing the right mouse down action.
    ///
    /// This method creates a context menu with breakpoint management options and displays it at the specified location.
    internal func showContextMenu(for lineNumber: Int,
                                  at point: CGPoint,
                                  with event: NSEvent) {
        let menu = NSMenu(title: "Breakpoint Menu")
        menu.addItem(withTitle: "Edit Breakpoint...",
                     action: #selector(contextMenuOption1(_:)),
                     keyEquivalent: "")
        menu.addItem(withTitle: "Disable Breakpoint...",
                     action: #selector(contextMenuOption2(_:)),
                     keyEquivalent: "")
        menu.addItem(withTitle: "Disable Other Breakpoints",
                     action: #selector(contextMenuOption2(_:)),
                     keyEquivalent: "")
        menu.addItem(withTitle: "Delete Breakpoint",
                     action: #selector(contextMenuOption2(_:)),
                     keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Reveal in Breakpoint Navigator",
                     action: #selector(contextMenuOption2(_:)),
                     keyEquivalent: "")
        for item in menu.items {
            item.representedObject = lineNumber
        }

        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    @objc private func contextMenuOption1(_ sender: NSMenuItem) {
        if let lineNumber = sender.representedObject as? Int {
            // Handle the action for Option 1
            print("Option 1 selected for line number \(lineNumber)")
        }
    }

    @objc private func contextMenuOption2(_ sender: NSMenuItem) {
        if let lineNumber = sender.representedObject as? Int {
            // Handle the action for Option 2
            print("Option 2 selected for line number \(lineNumber)")
        }
    }

    /// Creates a background image with a gradient and rounded corners.
    /// - Returns: A `NSImage` that can be used as a background for a line number.
    ///
    /// This method generates an image with a linear gradient between two specified colors. It also applies
    /// rounded corners to the image. This image is intended to be used as a background for selected line numbers
    /// to visually distinguish them, such as when a breakpoint is set.
    internal func createBackgroundImage() -> NSImage {
        let size = NSSize(width: maxWidth, height: font.lineHeight)
        let image = NSImage(size: size)
        image.lockFocus()

        let startingColor = NSColor(calibratedRed: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        let endingColor = NSColor(calibratedRed: 0.0, green: 0.318, blue: 0.8, alpha: 1.0)
        let gradient = NSGradient(colors: [startingColor, endingColor])!

        let cornerRadius: CGFloat = 5
        let path = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: cornerRadius, yRadius: cornerRadius)

        path.addClip()
        gradient.draw(in: path.bounds, angle: 90)

        image.unlockFocus()
        return image
    }

    /// Presents a popover for configuring a breakpoint at a specified line number.
    /// - Parameters:
    ///   - line: The line number where the popover should be presented.
    ///   - rect: The rectangle defining the area where the popover should be anchored.
    ///
    /// This method instantiates a `BreakpointViewController` and presents it in a popover
    /// at the location of the specified line number. The popover is configured to dismiss
    /// when the user interacts with a different UI element.
    func showBreakpointPopover(at line: Int, rect: CGRect) {
        let breakpointViewController = BreakpointViewController()

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 160) // Adjust as needed
        popover.behavior = .transient
        popover.contentViewController = breakpointViewController
        popover.animates = true

        popover.show(relativeTo: rect, of: self, preferredEdge: .maxY)
    }
}
