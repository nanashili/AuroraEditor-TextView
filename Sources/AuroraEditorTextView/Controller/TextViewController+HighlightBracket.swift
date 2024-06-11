//
//  TextViewController+HighlightRange.swift
//
//  Created by Nanashi Li on 9/12/23.
//

import AppKit

extension TextViewController {
    /// Highlights matching bracket pairs within the selected text.
    ///
    /// This method iterates over each range within the text view's current text selections.
    /// For each range, it checks the preceding character. If this character is a bracket,
    /// it searches for its matching pair and highlights both. The method supports different
    /// highlighting styles based on the `bracketPairHighlight` property.
    internal func highlightSelectionPairs() {
//        guard let bracketPairHighlight = bracketPairHighlight else { return }
        removeHighlightLayers()

        for range in textView.selectionManager.textSelections.map({ $0.range }) {
            guard range.isEmpty, range.location > 0 else { continue }

            if let precedingCharacter = textView.textStorage.substring(from: NSRange(location: range.location - 1, length: 1)) {
                highlightMatchingPair(for: precedingCharacter, at: range.location)
            }
        }
    }

    /// Highlights a matching bracket pair for a given character at a specific location.
    ///
    /// - Parameters:
    ///   - character: The character for which a matching bracket pair is to be found.
    ///   - location: The location of the character in the text view.
    ///
    /// The method determines if the character is an opening or closing bracket and
    /// initiates a search in the appropriate direction (forward or backward).
    private func highlightMatchingPair(for character: String, at location: Int) {
        for pair in BracketPairs.allValues {
            if character == pair.0 {
                // Forward search for closing bracket
                processPair(pair.0, pair.1, from: location, reverse: false)
            } else if character == pair.1 && location - 1 > 0 {
                // Backward search for opening bracket
                processPair(pair.1, pair.0, from: location - 1, reverse: true)
            }
        }
    }

    /// Processes and highlights a bracket pair.
    ///
    /// - Parameters:
    ///   - close: The closing bracket character.
    ///   - open: The opening bracket character.
    ///   - location: The starting location for the search.
    ///   - reverse: A Boolean value indicating whether the search should be performed in reverse.
    ///
    /// This method calculates the limit for the search range and invokes `findClosingPair`
    /// to locate the matching bracket. If found, it highlights the character at the located index.
    private func processPair(_ close: String, _ open: String, from location: Int, reverse: Bool) {
        let limit = reverse ?
        max((textView.visibleTextRange?.location ?? 0) - 4096, textView.documentRange.location) :
        min(NSMaxRange(textView.visibleTextRange ?? .zero) + 4096, NSMaxRange(textView.documentRange))

        if let characterIndex = findClosingPair(close, open, from: location, limit: limit, reverse: reverse) {
            highlightCharacter(characterIndex)
            guard let bracketPairHighlight = bracketPairHighlight else {
                return
            }
            if bracketPairHighlight.highlightsSourceBracket {
                highlightCharacter(location - (reverse ? 1 : 0))
            }
        }
    }

    /// Finds the index of a closing bracket pair.
    ///
    /// - Parameters:
    ///   - close: The closing bracket character.
    ///   - open: The opening bracket character.
    ///   - from: The starting location for the search.
    ///   - limit: The limit location for the search.
    ///   - reverse: A Boolean value indicating whether the search should be performed in reverse.
    /// - Returns: An optional integer representing the found location of the closing bracket.
    ///
    /// This method searches for a matching closing bracket for a given opening bracket (or vice versa)
    /// starting from a specific location and within a given limit. The search can be performed in
    /// either forward or reverse direction.
    internal func findClosingPair(_ close: String, _ open: String, from: Int, limit: Int, reverse: Bool) -> Int? {
        // Ensure valid range calculation
        let rangeLocation = reverse ? max(limit, 0) : from
        let rangeLength = reverse ? max(from - limit, 0) : max(limit - from, 0)
        let searchRange = NSRange(location: rangeLocation, length: rangeLength)

        var options: NSString.EnumerationOptions = .byCaretPositions
        if reverse {
            options.insert(.reverse)
        }

        var closeCount = 0
        var index: Int?
        textView.textStorage.mutableString.enumerateSubstrings(
            in: searchRange,
            options: options,
            using: { substring, range, _, stop in
                if substring == close {
                    closeCount += 1
                } else if substring == open {
                    closeCount -= 1
                }

                if closeCount < 0 {
                    index = range.location
                    stop.pointee = true
                }
            }
        )
        return index
    }

    /// Highlights a character at a given location.
    ///
    /// - Parameters:
    ///   - location: The location of the character to be highlighted.
    ///   - scrollToRange: A Boolean value indicating whether the text view should scroll to the highlighted range.
    ///
    /// Depending on the current `bracketPairHighlight` style, this method creates a highlight layer
    /// and adds it to the text view. It supports different styles like flash, bordered, and underline.
    private func highlightCharacter(_ location: Int, scrollToRange: Bool = false) {
        guard let bracketPairHighlight = bracketPairHighlight,
              let rectToHighlight = textView.layoutManager?.rectForOffset(location) else {
            return
        }

        let layer = createHighlightLayer(for: bracketPairHighlight, in: rectToHighlight)

        // Insert above selection but below text
        textView.layer?.insertSublayer(layer, at: 1)

        if bracketPairHighlight == .flash {
            addFlashAnimation(to: layer, rectToHighlight: rectToHighlight)
        }

        highlightLayers.append(layer)

        if scrollToRange {
            textView.scrollToVisible(rectToHighlight)
        }
    }

    /// Creates a highlight layer for a given style and rect.
    ///
    /// - Parameters:
    ///   - highlightStyle: The style of highlighting to be applied.
    ///   - rect: The rectangle area where the highlight should be applied.
    /// - Returns: A `CAShapeLayer` configured with the specified highlight style.
    ///
    /// This method creates and configures a `CAShapeLayer` based on the specified `BracketPairHighlight` style.
    private func createHighlightLayer(for highlightStyle: BracketPairHighlight, in rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()

        var adjustedRect = rect
        switch highlightStyle {
        case .flash:
            adjustedRect.size.width += 4
            adjustedRect.origin.x -= 2

            layer.applyFlashStyle()
        case .bordered(let borderColor):
            layer.applyBorderedStyle(borderColor: borderColor)
        case .underline(let underlineColor):
            layer.applyUnderlineStyle(underlineColor: underlineColor, 
                                      in: adjustedRect,
                                      lineHeightMultiple: lineHeightMultiple)
        }

        layer.frame = adjustedRect
        return layer
    }

    /// Adds a flash animation to a layer.
    ///
    /// - Parameters:
    ///   - layer: The layer to which the animation is to be added.
    ///   - rectToHighlight: The rectangle area of the text to be highlighted.
    ///
    /// This method creates and adds a group of animations to the specified layer. The animations
    /// include changes in opacity, position, and bounds to create a flashing effect.
    private func addFlashAnimation(to layer: CALayer, rectToHighlight: CGRect) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock { [weak self] in
                // Safely unwrapping 'self' to avoid retain cycles
                guard let strongSelf = self else { return }

                if let index = strongSelf.highlightLayers.firstIndex(of: layer) {
                    strongSelf.highlightLayers.remove(at: index)
                }
                layer.removeFromSuperlayer()
            }

            let duration = 0.75
            let group = CAAnimationGroup()
            group.duration = duration

            let opacityAnim = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim.duration = duration
            opacityAnim.values = [1.0, 1.0, 0.0]
            opacityAnim.keyTimes = [0, 0.8, 1]

            let positionAnim = self.createPositionAnimation(for: rectToHighlight, withDuration: duration)

            let betweenSize = rectToHighlight.insetBy(dx: -2, dy: -2)
            let boundsAnim = CAKeyframeAnimation(keyPath: "bounds")
            boundsAnim.keyTimes = [0, 0.05, 1]
            boundsAnim.values = [NSValue(rect: rectToHighlight), NSValue(rect: betweenSize), NSValue(rect: rectToHighlight)]
            boundsAnim.duration = duration

            group.animations = [opacityAnim, boundsAnim, positionAnim]
            layer.add(group, forKey: "flashAnimation")
            CATransaction.commit()
        }
    }

    /// Creates a position-based keyframe animation for a given rectangle.
    ///
    /// - Parameters:
    ///   - rect: The `CGRect` for which the animation is created. The animation moves the position of the center of this rectangle.
    ///   - duration: The duration of the animation in seconds.
    /// - Returns: A configured `CAKeyframeAnimation` object.
    ///
    /// The function creates an animation that alters the position of a layer. It starts from the center of the provided rectangle,
    /// moves it slightly upwards and to the left (by 2 points in both x and y direction), and then returns to the original position.
    /// This creates a subtle 'nudging' effect. The key times for the animation are set at the start (0%), near the start (5%),
    /// and at the end (100%) of the total duration, creating a quick movement at the beginning and then holding the position
    /// until the end.
    private func createPositionAnimation(for rect: CGRect, withDuration duration: TimeInterval) -> CAKeyframeAnimation {
        let positionAnim = CAKeyframeAnimation(keyPath: "position")
        positionAnim.keyTimes = [0, 0.05, 1]
        let originalPosition = CGPoint(x: rect.midX, y: rect.midY)
        let offsetPosition = CGPoint(x: rect.midX - 2, y: rect.midY - 2)
        positionAnim.values = [NSValue(point: originalPosition), NSValue(point: offsetPosition), NSValue(point: originalPosition)]
        positionAnim.duration = duration
        return positionAnim
    }

    /// Removes all highlight layers from the text view.
    ///
    /// This method iterates through all the highlight layers added to the text view and removes them.
    /// It also clears the `highlightLayers` array.
    internal func removeHighlightLayers() {
        highlightLayers.forEach { layer in
            layer.removeFromSuperlayer()
        }
        highlightLayers.removeAll()
    }
}
