//
//  File.swift
//  
//
//  Created by Nanashi Li on 2023/12/24.
//

import AppKit
import Foundation

extension TextView {

    // This method repositions the sticky header view to be at the top of the visible area.
    public func repositionStickyHeaderView() {
    }

    public func updateStickyHeaderView() {
        repositionStickyHeaderView()
    }

    public override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        // Call the method to adjust the position of the sticky header view.
        repositionStickyHeaderView()
    }
}
