//
//  HighlightRange.swift
//
//
//  Created by Nanashi Li on 29/12/23.
//

import Foundation

/// Represents the range of text to be highlighted, optionally including the name of the capture
/// and the captured text itself.
public struct HighlightRange {
    // The range of text to be highlighted.
    let range: NSRange
    // The optional name of the capture associated with this highlight.
    let capture: CaptureName?
    // The optional text captured within this range.
    let captureText: String?

    /// Initializes a new HighlightRange with the specified properties.
    /// - Parameters:
    ///   - range: The range of text to be highlighted.
    ///   - capture: The optional name of the capture, defaulting to `nil`.
    ///   - captureText: The optional text captured within this range, defaulting to `nil`.
    init(range: NSRange,
         capture: CaptureName? = nil,
         captureText: String? = nil) {
        self.range = range
        self.capture = capture
        self.captureText = captureText
    }
}

