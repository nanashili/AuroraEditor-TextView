//
//  Highlighter.swift
//
//
//  Created by Khan Winter on 9/12/22.
//

import Foundation
import AppKit
import AuroraEditorInputView
import SwiftTreeSitter
import AuroraEditorLanguage

/// The `Highlighter` class handles efficiently highlighting the `TextView` it's provided with.
/// It will listen for text and visibility changes, and highlight syntax as needed.
///
/// One should rarely have to direcly modify or call methods on this class. Just keep it alive in
/// memory and it will listen for bounds changes, text changes, etc. However, to completely invalidate all
/// highlights use the ``invalidate()`` method to re-highlight all (visible) text, and the ``setLanguage``
/// method to update the highlighter with a new language if needed.
class Highlighter: NSObject {

    // MARK: - Index Sets

    /// Any indexes that highlights have been requested for, but haven't been applied.
    /// Indexes/ranges are added to this when highlights are requested and removed
    /// after they are applied
    private var pendingSet: IndexSet = .init()

    /// The set of valid indexes
    private var validSet: IndexSet = .init()

    /// The range of the entire document
    private var entireTextRange: Range<Int> {
        return 0..<(textView.textStorage.length)
    }

    /// The set of visible indexes in tht text view
    lazy private var visibleSet: IndexSet = {
        return IndexSet(integersIn: textView.visibleTextRange ?? NSRange())
    }()

    // MARK: - UI

    /// The text view to highlight
    private unowned var textView: TextView

    /// The editor theme
    private var theme: EditorTheme

    /// The object providing attributes for captures.
    private weak var attributeProvider: ThemeAttributesProviding!

    /// The current language of the editor.
    private var language: CodeLanguage

    /// Calculates invalidated ranges given an edit.
    private weak var highlightProvider: HighlightProviding?

    /// The length to chunk ranges into when passing to the highlighter.
    fileprivate let rangeChunkLimit = 256

    private var fontCache: [String: NSFont] = [:]

    // MARK: - Init

    /// Initializes the `Highlighter`
    /// - Parameters:
    ///   - textView: The text view to highlight.
    ///   - treeSitterClient: The tree-sitter client to handle tree updates and highlight queries.
    ///   - theme: The theme to use for highlights.
    init(
        textView: TextView,
        highlightProvider: HighlightProviding?,
        theme: EditorTheme,
        attributeProvider: ThemeAttributesProviding,
        language: CodeLanguage
    ) {
        self.textView = textView
        self.highlightProvider = highlightProvider
        self.theme = theme
        self.attributeProvider = attributeProvider
        self.language = language

        super.init()

        highlightProvider?.setUp(textView: textView, codeLanguage: language)

        if let scrollView = textView.enclosingScrollView {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(visibleTextChanged(_:)),
                                                   name: NSView.frameDidChangeNotification,
                                                   object: scrollView)

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(visibleTextChanged(_:)),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: scrollView.contentView)
        }
    }

    // MARK: - Public

    /// Invalidates all text in the textview. Useful for updating themes.
    public func invalidate() {
        updateVisibleSet()
        invalidate(range: NSRange(entireTextRange))
    }

    /// Sets the language and causes a re-highlight of the entire text.
    /// - Parameter language: The language to update to.
    public func setLanguage(language: CodeLanguage) {
        highlightProvider?.setUp(textView: textView, codeLanguage: language)
        invalidate()
    }

    /// Sets the highlight provider. Will cause a re-highlight of the entire text.
    /// - Parameter provider: The provider to use for future syntax highlights.
    public func setHighlightProvider(_ provider: HighlightProviding) {
        self.highlightProvider = provider
        highlightProvider?.setUp(textView: textView, codeLanguage: language)
        invalidate()
    }

    deinit {
        self.attributeProvider = nil
    }
}

// MARK: - Highlighting

private extension Highlighter {

    /// Invalidates a given range and adds it to the queue to be highlighted.
    /// - Parameter range: The range to invalidate.
    func invalidate(range: NSRange) {
        let set = IndexSet(integersIn: range)

        if set.isEmpty {
            return
        }

        validSet.subtract(set)

        highlightNextRange()
    }

    /// Begins highlighting any invalid ranges
    func highlightNextRange() {
        // If there aren't any more ranges to highlight, don't do anything, otherwise continue highlighting
        // any available ranges.
        guard let range = getNextRange() else {
            return
        }

        highlight(range: range)
        highlightNextRange()
    }

    /**
     Highlights text within a specified range based on predefined patterns and attributes.

     - Parameters:
     - rangeToHighlight: The range of text to highlight.

     This method highlights text within the given range based on predefined patterns and attributes. It utilizes a set of regular expressions to identify specific patterns within comments and applies corresponding attributes to those patterns.

     - Note: This method is typically called to update text highlighting when text changes in an NSTextView.

     - Important: Ensure that `highlightProvider` and `attributeProvider` properties are set before calling this method.

     - SeeAlso: `attributeProvider`, `highlightProvider`
     */
    func highlight(range rangeToHighlight: NSRange) {
        // Insert the specified range into the `pendingSet` to track ongoing highlighting.
        pendingSet.insert(integersIn: rangeToHighlight)

        // Query for highlight ranges within the specified range using the `highlightProvider`.
        highlightProvider?.queryHighlightsFor(
            textView: self.textView,
            range: rangeToHighlight
        ) { [weak self] highlightRanges in
            // Check if self (the object invoking this method) is still in memory.
            guard let attributeProvider = self?.attributeProvider,
                  let textView = self?.textView else { return }

            // Remove the specified range from the `pendingSet` as highlighting is complete.
            self?.pendingSet.remove(integersIn: rangeToHighlight)

            // Check if the `visibleSet` intersects with the specified range. If not, no further action is needed.
            guard self?.visibleSet.intersects(integersIn: rangeToHighlight) ?? false else {
                return
            }

            // Add the specified range to the `validSet` as it has been successfully highlighted.
            self?.validSet.formUnion(IndexSet(integersIn: rangeToHighlight))

            // Begin editing the text storage for the NSTextView.
            textView.layoutManager.beginTransaction()
            textView.textStorage.beginEditing()

            // Create a set of indexes that were not highlighted.
            var ignoredIndexes = IndexSet(integersIn: rangeToHighlight)

            // Define predefined patterns and corresponding regular expressions.
            let patterns: [String: String] = [
                "todo": "^//\\s*TODO:.*",
                "fixme": "^//\\s*FIXME:.*",
                "mark": "^//\\s*MARK:.*"
            ]

            // Precompile regular expressions for pattern matching.
            let regexes = patterns.compactMapValues { try? NSRegularExpression(pattern: $0, options: []) }

            // Iterate through each highlight and modify the textStorage accordingly.
            for highlight in highlightRanges {
                // Apply default attributes for the current capture.
                var defaultAttributes = attributeProvider.attributesFor(highlight.capture)
                textView.textStorage.setAttributes(defaultAttributes, range: highlight.range)

                // Check if the current highlight is within a comment and capture the text.
                if highlight.capture == .comment, let captureText = highlight.captureText {
                    // Process TODO comments within the highlight.
                    self?.processTodoComment(highlight: highlight, captureText: captureText, regexes: regexes, defaultAttributes: defaultAttributes)
                } else if highlight.capture == .include || highlight.capture == .constructor
                            || highlight.capture == .keyword || highlight.capture == .boolean
                            || highlight.capture == .keywordReturn || highlight.capture == .keywordFunction
                            || highlight.capture == .repeat || highlight.capture == .conditional
                            || highlight.capture == .tag || highlight.capture == .variableBuiltin {

                    // Apply bold font to certain captures.
                    if let currentFont = defaultAttributes[.font] as? NSFont {
                        let boldFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(.bold)
                        let boldFont = NSFont(descriptor: boldFontDescriptor, size: currentFont.pointSize)
                        defaultAttributes[.font] = boldFont
                        textView.textStorage.setAttributes(defaultAttributes, range: highlight.range)
                    }
                } else if highlight.capture == .error {
                    
                }

                // Remove highlighted indexes from the "ignored" indexes.
                ignoredIndexes.remove(integersIn: highlight.range)
            }

            // Apply normal attributes to any remaining unhighlighted text.
            for ignoredRange in ignoredIndexes.rangeView {
                textView.textStorage.setAttributes(
                    attributeProvider.attributesFor(nil),
                    range: NSRange(ignoredRange)
                )
            }

            // End editing the text storage for the NSTextView.
            textView.textStorage.endEditing()
            textView.layoutManager.endTransaction()
        }
    }

    /**
     Processes TODO comments within a highlight range.

     - Parameters:
     - highlight: The highlight range to process.
     - captureText: The text captured within the highlight range.
     - regexes: A dictionary of predefined regular expressions for pattern matching.
     - defaultAttributes: The default attributes for the highlight range.

     This method processes TODO comments within a specified highlight range. It splits the comment into lines, applies attributes based on predefined patterns, and handles font styling for certain patterns.

     - Note: This method is called internally by the `highlight(range:)` method.

     - SeeAlso: `highlight(range:)`
     */
    private func processTodoComment(highlight: HighlightRange,
                                     captureText: String,
                                     regexes: [String: NSRegularExpression],
                                     defaultAttributes: [NSAttributedString.Key: Any]) {
        // Obtain the full comment text as an NSString.
        let fullText = textView.textStorage.string as NSString
        // Get the range of the comment within the text.
        let commentRange = highlight.range
        // Split the comment text into individual lines.
        let lines = fullText.substring(with: commentRange).split(separator: "\n")

        var locationOffset = commentRange.location

        for line in lines {
            let lineNSString = NSString(string: String(line))
            // Define the range of the current line within the comment.
            let lineRange = NSRange(location: locationOffset, length: lineNSString.length)

            // Iterate through the predefined patterns and corresponding regular expressions.
            for (patternKey, regex) in regexes {
                // Check if a match is found within the current line.
                if let match = regex.firstMatch(in: String(line), options: [], range: NSRange(location: 0, length: lineNSString.length)) {
                    // Apply custom attributes based on the pattern key and match information.
                    applyCustomAttributes(patternKey: patternKey, matchRange: match.range, lineRange: lineRange, defaultAttributes: defaultAttributes)
                }
            }

            // Update the location offset for the next line.
            locationOffset += lineNSString.length + 1
        }
    }

    /**
     Applies custom attributes to a specific range within text.

     - Parameters:
     - patternKey: The key identifying the pattern being matched.
     - matchRange: The range of the matched pattern within a line.
     - lineRange: The range of the line containing the matched pattern.
     - defaultAttributes: The default attributes for the text.

     This method applies custom attributes to a specific range within text based on the provided parameters. It handles font styling and other customizations for specific patterns.

     - Note: This method is called internally by the `processTodoComment` method.

     - SeeAlso: `processTodoComment`
     */
    private func applyCustomAttributes(patternKey: String,
                                        matchRange: NSRange,
                                        lineRange: NSRange,
                                        defaultAttributes: [NSAttributedString.Key: Any]) {
        var customAttributes = defaultAttributes
        if ["todo", "fixme", "mark"].contains(patternKey) {
            if let cachedFont = fontCache[patternKey] {
                customAttributes[.font] = cachedFont
            } else if let currentFont = customAttributes[.font] as? NSFont {
                let boldFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(.bold)
                if let boldFont = NSFont(descriptor: boldFontDescriptor, size: currentFont.pointSize + 1) {
                    fontCache[patternKey] = boldFont
                    customAttributes[.font] = boldFont
                }
            }
        }


        let finalMatchRange = NSRange(location: lineRange.location + matchRange.location, length: matchRange.length)
        textView.textStorage.setAttributes(customAttributes, range: finalMatchRange)
    }

    /// Gets the next `NSRange` to highlight based on the invalid set, visible set, and pending set.
    /// - Returns: An `NSRange` to highlight if it could be fetched.
    func getNextRange() -> NSRange? {
        let set: IndexSet = IndexSet(integersIn: entireTextRange) // All text
            .subtracting(validSet) // Subtract valid = Invalid set
            .intersection(visibleSet) // Only visible indexes
            .subtracting(pendingSet) // Don't include pending indexes

        guard let range = set.rangeView.first else {
            return nil
        }

        // Chunk the ranges in sets of rangeChunkLimit characters.
        return NSRange(location: range.lowerBound,
                       length: min(rangeChunkLimit, range.upperBound - range.lowerBound))
    }

}

// MARK: - Visible Content Updates

private extension Highlighter {
    private func updateVisibleSet() {
        if let newVisibleRange = textView.visibleTextRange {
            visibleSet = IndexSet(integersIn: newVisibleRange)
        }
    }

    /// Updates the view to highlight newly visible text when the textview is scrolled or bounds change.
    @objc func visibleTextChanged(_ notification: Notification) {
        updateVisibleSet()

        // Any indices that are both *not* valid and in the visible text range should be invalidated
        let newlyInvalidSet = visibleSet.subtracting(validSet)

        for range in newlyInvalidSet.rangeView.map({ NSRange($0) }) {
            invalidate(range: range)
        }
    }
}

// MARK: - NSTextStorageDelegate

extension Highlighter: NSTextStorageDelegate {
    /// Processes an edited range in the text.
    /// Will query tree-sitter for any updated indices and re-highlight only the ranges that need it.
    func textStorage(_ textStorage: NSTextStorage,
                     didProcessEditing editedMask: NSTextStorageEditActions,
                     range editedRange: NSRange,
                     changeInLength delta: Int) {
        // This method is called whenever attributes are updated, so to avoid re-highlighting the entire document
        // each time an attribute is applied, we check to make sure this is in response to an edit.
        guard editedMask.contains(.editedCharacters) else {
            return
        }

        let range = NSRange(location: editedRange.location, length: editedRange.length - delta)
        if delta > 0 {
            visibleSet.insert(range: editedRange)
        }

        highlightProvider?.applyEdit(textView: self.textView,
                                     range: range,
                                     delta: delta) { [weak self] invalidatedIndexSet in
            let indexSet = invalidatedIndexSet
                .union(IndexSet(integersIn: editedRange))
                // Only invalidate indices that are visible.
                .intersection(self?.visibleSet ?? .init())

            for range in indexSet.rangeView {
                self?.invalidate(range: NSRange(range))
            }
        }
    }
}
