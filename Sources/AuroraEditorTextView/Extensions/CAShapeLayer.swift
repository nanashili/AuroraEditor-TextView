//
//  CAShapeLayer.swift
//  
//
//  Created by Nanashi Li on 2023/12/20.
//

import AppKit

extension CAShapeLayer {
    func applyFlashStyle() {
        self.cornerRadius = 3.0
        self.backgroundColor = NSColor.yellow.cgColor
        self.shadowColor = NSColor.black.cgColor
        self.shadowOpacity = 0.3
        self.shadowOffset = CGSize(width: 0, height: 1)
        self.shadowRadius = 3.0
        self.opacity = 0.0
    }

    func applyBorderedStyle(borderColor: NSColor) {
        self.borderColor = borderColor.cgColor
        self.cornerRadius = 2.5
        self.borderWidth = 0.5
        self.opacity = 1.0
    }

    func applyUnderlineStyle(underlineColor: NSColor, 
                             in rect: CGRect,
                             lineHeightMultiple: CGFloat) {
        let path = CGMutablePath()
        let pathY = rect.maxY - (rect.height * (lineHeightMultiple - 1))/4
        path.move(to: CGPoint(x: rect.minX, y: pathY))
        path.addLine(to: CGPoint(x: rect.maxX, y: pathY))
        self.path = path
        self.lineWidth = 1.0
        self.lineCap = .round
        self.strokeColor = underlineColor.cgColor
        self.opacity = 1.0
    }
}
