//
//  TreeSitterClient+Highlight.swift
//  
//
//  Created by Khan Winter on 3/10/23.
//

import Foundation
import SwiftTreeSitter
import AuroraEditorLanguage

extension TreeSitterClient {
    internal func queryHighlightsForRange(
        range: NSRange,
        runningAsync: Bool,
        completion: @escaping (([HighlightRange]) -> Void)
    ) {
        logger.debug("Starting queryHighlightsForRange.")
        stateLock.lock()
        guard let textView, let state = state?.copy() else { return }
        stateLock.unlock()

        var highlights: [HighlightRange] = []
        var injectedSet = IndexSet(integersIn: range)

        logger.debug("Query injected only if a layer's ranges intersects with `range`")
        for layer in state.layers where layer.id != state.primaryLayer.id {
            // Query injected only if a layer's ranges intersects with `range`
            for layerRange in layer.ranges {
                logger.debug("RANGE=\(layerRange)")
                if let rangeIntersection = range.intersection(layerRange) {
                    logger.debug("We have a range intersection")

                    highlights.append(contentsOf: queryLayerHighlights(
                        layer: layer,
                        textView: textView,
                        range: rangeIntersection
                    ))

                    injectedSet.remove(integersIn: rangeIntersection)
                }
            }
        }

        logger.debug("Query primary for any ranges that weren't used in the injected layers.")
        // Query primary for any ranges that weren't used in the injected layers.
        for range in injectedSet.rangeView {
            highlights.append(contentsOf: queryLayerHighlights(
                layer: state.layers[0],
                textView: textView,
                range: NSRange(range)
            ))
        }

        if !runningAsync {
            logger.debug("Running on current thread \(Thread.current) which \(Thread.isMainThread ? "is" : "isn't") a main thread")
            completion(highlights)
        } else {
            DispatchQueue.main.async {
                self.logger.debug("Async running on mainthread")
                completion(highlights)
            }
        }
    }

    internal func queryHighlightsForRangeAsync(
        range: NSRange,
        completion: @escaping (([HighlightRange]) -> Void)
    ) {
        if queuedQueries.count > 255 { // It seems to crash on 256
            logger.error("Outstanding queries are more then 255, we do not append.")
            return
        }
        queuedQueries.append {
            // Github issue: #664
            // ERROR: Thread 8: EXC_BAD_ACCESS (code=1, address=0x48)
            self.queryHighlightsForRange(range: range, runningAsync: true, completion: completion)
        }

        beginTasksIfNeeded()
    }

    /// Queries the given language layer for any highlights.
    /// - Parameters:
    ///   - layer: The layer to query.
    ///   - textView: A text view to use for contextual data.
    ///   - range: The range to query for.
    /// - Returns: Any ranges to highlight.
    internal func queryLayerHighlights(
        layer: LanguageLayer,
        textView: HighlighterTextView,
        range: NSRange
    ) -> [HighlightRange] {
        guard let tree = layer.tree,
              let rootNode = tree.rootNode else {
            return []
        }

        // This needs to be on the main thread since we're going to use the `textProvider` in
        // the `highlightsFromCursor` method, which uses the textView's text storage.
        guard let cursor = layer.languageQuery?.execute(node: rootNode, in: tree) else {
            return []
        }
        cursor.setRange(range)
        cursor.matchLimit = Constants.treeSitterMatchLimit

        return highlightsFromCursor(cursor: ResolvingQueryCursor(cursor: cursor), 
                                    includedRange: range,
                                    captureText: textView.stringForRange(range) ?? "")
    }

    /// Resolves a query cursor to the highlight ranges it contains.
    /// **Must be called on the main thread**
    /// - Parameters:
    ///     - cursor: The cursor to resolve.
    ///     - includedRange: The range to include highlights from.
    /// - Returns: Any highlight ranges contained in the cursor.
    internal func highlightsFromCursor(cursor: ResolvingQueryCursor,
                                       includedRange: NSRange,
                                       captureText: String) -> [HighlightRange] {
        cursor.prepare(with: self.textProvider)

        return cursor.flatMap { $0.captures }
            .compactMap { capture in
                // Ensure the capture's range intersects with the included range.
                guard let intersectionRange = capture.range.intersection(includedRange),
                      intersectionRange.length > 0,
                      let captureName = CaptureName.fromString(capture.name ?? "") else {
                    return nil
                }
                return HighlightRange(range: intersectionRange, capture: captureName, captureText: captureText)
            }
    }
}
