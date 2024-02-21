//
//  File.swift
//  
//
//  Created by Nanashi Li on 2023/12/24.
//

import Foundation
import AppKit

class StickyHeaderView: NSView {
    private let titleLabel = NSTextField()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.selectedTextBackgroundColor.withSystemEffect(.disabled).withAlphaComponent(0.15).cgColor
        // Configure the title label if needed
        titleLabel.stringValue = "Your Header Title" // Set the title string
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = NSColor.white // Change text color as needed
        titleLabel.backgroundColor = NSColor.clear
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.sizeToFit()
        titleLabel.frame.origin = CGPoint(x: 10, y: (frame.height - titleLabel.frame.height) / 2) // Adjust the position as needed

        addSubview(titleLabel)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // If you want to draw a custom design, implement it here

        // For example, drawing a bottom border line:
        let line = NSBezierPath()
        line.move(to: NSPoint(x: 0, y: 0))
        line.line(to: NSPoint(x: dirtyRect.width, y: 0))
        line.lineWidth = 1.0 // Adjust the line width as needed
        NSColor.separatorColor.setStroke() // Change the line color as needed
        line.stroke()
    }
}

