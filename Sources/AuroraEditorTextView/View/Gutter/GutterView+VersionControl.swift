//
//  GutterView+VersionControl.swift
//
//
//  Created by Nanashi Li on 2023/12/21.
//

import Foundation
import AppKit

extension GutterView {

    // This method is called to draw indicators for changed lines.
    public func drawChangedLinesIndicator(_ context: CGContext,
                                          lineHeight: CGFloat,
                                          highlightColor: NSColor = .systemBlue,
                                          outlineColor: NSColor = .systemBlue,
                                          marginPercentage: CGFloat = 0.11) {
        guard lineHeight >= 0 else { return } // Ensure non-negative line height

        let scaledLineHeight: CGFloat = lineHeight * 10
        let roundedCornerWidth: CGFloat = 5.0
        let margin = bounds.width * marginPercentage
        let highlightCGColor = highlightColor.withAlphaComponent(0.2).cgColor
        let outlineCGColor = outlineColor.cgColor

        context.saveGState()
        context.setLineWidth(1.0)

        // Pre-calculate the hover highlight rectangle width
        let hoverHighlightRectWidth = bounds.width - (margin * 2)

        for range in highlightedLineRanges {
            if range.lowerBound <= range.upperBound {
                let startYPos = calculateYPosition(for: range.lowerBound + 1, lineHeight: scaledLineHeight)
                let totalHeight = max(scaledLineHeight, scaledLineHeight * CGFloat(range.upperBound - range.lowerBound + 1))

                let highlightRectWidth = 4.0
                var highlightRect = CGRect(x: margin, y: startYPos, width: highlightRectWidth, height: totalHeight)

                let path = CGPath(
                    roundedRect: highlightRect,
                    cornerWidth: roundedCornerWidth,
                    cornerHeight: roundedCornerWidth,
                    transform: nil
                )

                context.addPath(path)
                context.setFillColor(highlightCGColor)
                context.setStrokeColor(outlineCGColor)
                context.drawPath(using: .fillStroke)

                if let hovered = hoveredDiffRangeIndex, range.contains(hovered) {
                    highlightRect = CGRect(x: margin, y: startYPos, width: hoverHighlightRectWidth, height: totalHeight)

                    let hoverPath = CGPath(roundedRect: highlightRect,
                                           cornerWidth: roundedCornerWidth,
                                           cornerHeight: roundedCornerWidth,
                                           transform: nil)

                    context.addPath(hoverPath)
                    context.setStrokeColor(NSColor.systemBlue.cgColor)
                    context.drawPath(using: .stroke)
                }
            }
        }

        context.restoreGState()
    }

    private func calculateYPosition(for lineNumber: Int, lineHeight: CGFloat) -> CGFloat {
        return lineHeight * CGFloat(lineNumber)
    }

    // MARK: - Git Diff Handling

    // This function takes a diff string and updates the highlightedLineRanges array.
    public func parseDiffRanges(diffStrings: [String]) {
        diffStrings.forEach { diffString in
            processDiffString(diffString)
        }

        needsDisplay = true
    }

    private func processDiffString(_ diffString: String) {
        let diffComponents = diffString.split(separator: " ")
        guard diffComponents.count >= 4 else {
            return
        }

        // Helper function to process a diff component
        func processComponent(_ component: Substring, isDeletion: Bool) {
            let rangeComponent = component.dropFirst() // Drops the first character ('-' or '+')
            if let range = parseDiffComponent(rangeComponent) {
                let startLine = isDeletion ? range.startLine : range.startLine - 1
                let endLine = startLine + range.count - 1

                if range.count > 0, startLine <= endLine {
                    let range = startLine...endLine
                    highlightedLineRanges.append(range)
                }
            }
        }

        // Process deletion component
        processComponent(diffComponents[1], isDeletion: true)

        // Process addition component
        processComponent(diffComponents[2], isDeletion: false)
    }

    private func parseDiffComponent(_ component: Substring) -> (startLine: Int, count: Int)? {
        let parts = component.split(separator: ",")

        // Parse start line
        guard let startLine = Int(parts.first ?? "") else {
            return nil
        }

        // Parse count, default to 1 if not provided
        let count = parts.count > 1 ? Int(parts[1]) : 1

        // Handle invalid count value
        if let count = count, count > 0 {
            return (startLine, count)
        } else {
            return nil
        }
    }

    public override func mouseMoved(with event: NSEvent) {
        let locationInView = self.convert(event.locationInWindow, from: nil)
        hoveredDiffRangeIndex = determineLineAtPoint(locationInView)
        self.needsDisplay = true
    }

    func determineLineAtPoint(_ point: CGPoint) -> Int? {
        let lineHeight: CGFloat = 20 // Assuming a fixed line height
        let line = Int(floor(point.y / lineHeight)) + 1
        return line <= highlightedLineRanges.flatMap({ $0 }).max() ?? 0 ? line : nil
    }
}
