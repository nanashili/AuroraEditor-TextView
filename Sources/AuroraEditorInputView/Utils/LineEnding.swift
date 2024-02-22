//
//  LineEnding.swift
//  
//
//  Created by Nanashi Li on 22/12/23.
//

import AppKit

/// An enumeration to represent the different types of line endings in a text document.
///
/// `LineEnding` provides an easy way to detect and work with various line ending characters
/// commonly used in different operating systems and text file formats.
public enum LineEnding: String, CaseIterable {
    /// The line feed (`\n`) character, used as the line ending in Unix-like systems.
    case lineFeed = "\n"

    /// The carriage return (`\r`) character, historically used as the line ending in Mac OS.
    case carriageReturn = "\r"

    /// The carriage return and line feed (`\r\n`) sequence, used as the line ending in Windows.
    case carriageReturnLineFeed = "\r\n"

    /// Initializes a `LineEnding` instance from a given line of text.
    ///
    /// This initializer examines the end of a string to determine the type of line ending it contains.
    /// It supports `\n`, `\r`, and `\r\n` as valid line endings.
    ///
    /// - Parameter line: The line of text from which to determine the line ending.
    /// - Returns: A `LineEnding` enumeration case if a line ending is detected, otherwise `nil`.
    public init?(line: String) {
        if line.hasSuffix(LineEnding.carriageReturnLineFeed.rawValue) {
            self = .carriageReturnLineFeed
        } else if line.hasSuffix(LineEnding.lineFeed.rawValue) {
            self = .lineFeed
        } else if line.hasSuffix(LineEnding.carriageReturn.rawValue) {
            self = .carriageReturn
        } else {
            return nil
        }
    }

    /// Detects the most common line ending in a given text storage.
    ///
    /// This method processes the text storage in concurrent chunks to efficiently determine
    /// the predominant line ending. It uses a histogram-based approach to count the occurrences
    /// of each line ending type and returns the most common one.
    ///
    /// - Parameters:
    ///   - lineStorage: The storage containing lines of text to be processed.
    ///   - textStorage: The `NSTextStorage` associated with the `lineStorage`.
    /// - Returns: The most common `LineEnding` in the given text storage. Defaults to `.lineFeed` if none is detected.
    public static func detectLineEnding(
        lineStorage: TextLineStorage<TextLine>,
        textStorage: NSTextStorage
    ) -> LineEnding {
        let processingQueue = DispatchQueue(label: "com.auroraeditor.textview.lineeding.queue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        var histogram: [LineEnding: Int] = [:]
        let histogramLock = NSLock()

        let chunkSize = 1024
        var startIndex = 0
        let totalLines = lineStorage.count

        while startIndex < totalLines {
            let endIndex = min(startIndex + chunkSize, totalLines)
            dispatchGroup.enter()
            processingQueue.async {
                var localHistogram: [LineEnding: Int] = [:]
                if endIndex > startIndex { // Do not parse if endIndex is higher than startIndex
                    for index in startIndex..<endIndex {
                        guard let line = lineStorage.getLine(atIndex: index),
                              let lineString = textStorage.substring(from: line.range),
                              let lineEnding = LineEnding(line: lineString) else {
                            continue
                        }
                        localHistogram[lineEnding, default: 0] += 1
                    }
                }
                histogramLock.lock()
                for (key, value) in localHistogram {
                    histogram[key, default: 0] += value
                }
                histogramLock.unlock()
                dispatchGroup.leave()
            }
            startIndex = endIndex
        }

        dispatchGroup.wait()

        return histogram.max(by: { $0.value < $1.value })?.key ?? .lineFeed
    }

    /// The UTF-16 length of the line ending character sequence.
    ///
    /// This property calculates the length of the line ending sequence in UTF-16 code units.
    /// It's useful for operations that need to know the length of the line ending for processing
    /// text in various string encodings.
    public var length: Int {
        rawValue.utf16.count
    }
}
