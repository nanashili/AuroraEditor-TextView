//
//  NSRange+InputEdit.swift
//  
//
//  Created by Khan Winter on 9/12/22.
//

import Foundation
import SwiftTreeSitter

extension InputEdit {
    init?(range: NSRange, delta: Int, oldEndPoint: Point) {
        let newEndLocation = NSMaxRange(range) + delta

        if newEndLocation < 0 {
            assertionFailure("Invalid range/delta")
            return nil
        }

        // TODO: - Ask why Neon only uses .zero for these
        let startPoint: Point = .zero
        let newEndPoint: Point = .zero

        self.init(startByte: UInt32(range.location * 2),
                  oldEndByte: UInt32(NSMaxRange(range) * 2),
                  newEndByte: UInt32(newEndLocation * 2),
                  startPoint: startPoint,
                  oldEndPoint: oldEndPoint,
                  newEndPoint: newEndPoint)
    }
}

extension NSRange {
    // swiftlint:disable line_length
    /// Modifies the range to account for an edit.
    /// Largely based on code from
    /// [tree-sitter](https://github.com/tree-sitter/tree-sitter/blob/ddeaa0c7f534268b35b4f6cb39b52df082754413/lib/src/subtree.c#L691-L720)
    mutating func applyInputEdit(_ edit: InputEdit) {
        let endIndex = NSMaxRange(self)
        let isPureInsertion = edit.oldEndByte == edit.startByte

        let startByteIndex = edit.startByte / 2
        let oldEndByteIndex = edit.oldEndByte / 2
        let newEndByteIndex = Int(edit.newEndByte) / 2

        // Edit is after the range
        if startByteIndex > endIndex {
            return
        }

        // Edit is entirely before this range
        if oldEndByteIndex < location {
            self.location += newEndByteIndex - Int(oldEndByteIndex)
        }
        // Edit starts before and extends into this range
        else if startByteIndex < location {
            length -= Int(oldEndByteIndex) - location
            location = newEndByteIndex
        }
        // Edit is an insertion at the beginning of the range
        else if startByteIndex == location && isPureInsertion {
            location = newEndByteIndex
        }
        // Edit is entirely within this range
        else if startByteIndex < endIndex || (startByteIndex == endIndex && isPureInsertion) {
            length = newEndByteIndex - location + (length - (Int(oldEndByteIndex) - location))
        }
    }
}
