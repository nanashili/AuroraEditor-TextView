//
//  NSLayoutManager.swift
//
//
//  Created by Nanashi Li on 2023/12/22.
//

import AppKit

extension NSLayoutManager {
    func characterRange(forGlyphRange glyphRange: NSRange, actualGlyphRange: NSRangePointer?) -> NSRange {
        return self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: actualGlyphRange)
    }

    func glyphRange(forLineNumber lineNumber: Int, textContainer: NSTextContainer) -> NSRange {
        var glyphIndex = 0, glyphLine = 0
        var range = NSRange(location: NSNotFound, length: 0)

        while glyphIndex < self.numberOfGlyphs {
            let glyphRange = NSRange(location: glyphIndex, length: 1)
            range = self.glyphRange(forBoundingRect: self.boundingRect(forGlyphRange: glyphRange,
                                                                       in: textContainer),
                                    in: textContainer)
            if glyphLine == lineNumber {
                return range
            }
            glyphIndex = NSMaxRange(range)
            glyphLine += 1
        }

        return range // Return an empty range if the line number is not found
    }
}
