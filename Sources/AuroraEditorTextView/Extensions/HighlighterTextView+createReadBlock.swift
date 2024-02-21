//
//  HighlighterTextView+createReadBlock.swift
//  
//
//  Created by Khan Winter on 5/20/23.
//

import Foundation
import SwiftTreeSitter

extension HighlighterTextView {
    func createReadBlock() -> Parser.ReadBlock {
        return { [weak self] byteOffset, _ in
            guard let strongSelf = self else { return nil }

            let limit = strongSelf.documentRange.length
            let location = byteOffset / 2
            let end = min(location + 1024, limit)

            // Ensure the location is within the bounds of the document
            guard location < end else {
                // Return nil if the read request is out of bounds
                return nil
            }

            let range = NSRange(location..<end)
            return strongSelf.stringForRange(range)?.data(using: String.nativeUTF16Encoding)
        }
    }
}
