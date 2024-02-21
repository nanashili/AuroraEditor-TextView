//
//  ViewReuseQueue.swift
//  
//
//  Created by Nanashi Li on 22/12/23.
//

import AppKit
import DequeModule

/// `ViewReuseQueue` manages a reusable queue of `NSView` objects.
/// It is designed to improve performance and memory efficiency in situations
/// where creating and destroying view instances frequently is costly.
public class ViewReuseQueue<View: NSView, Key: Hashable> {
    public var queuedViews: Deque<View> = []
    public var usedViews: [Key: View] = [:]

    /// Initializes a new instance of the view reuse queue.
    public init() { }

    /// Retrieves a reusable view for the specified key.
    /// If a view for the given key is currently in use, it returns that view.
    /// Otherwise, it dequeues a reusable view or creates a new one if none are available.
    ///
    /// - Parameter key: The key for which to find or create a view.
    /// - Returns: A view associated with the given key, either retrieved from the queue or newly created.
    public func getOrCreateView(forKey key: Key) -> View {
        if let usedView = usedViews[key] {
            return usedView
        } else {
            let view = queuedViews.popFirst() ?? View()
            view.prepareForReuse()
            usedViews[key] = view
            return view
        }
    }

    /// Enqueues a view associated with a specific key for reuse.
    /// This method removes the view from the 'used' pool and adds it to the queue of reusable views.
    ///
    /// - Parameter key: The key associated with the view to be enqueued for reuse.
    public func enqueueView(forKey key: Key) {
        guard let view = usedViews.removeValue(forKey: key) else { return }
        queuedViews.append(view)
        view.prepareForReuse()
    }

    /// Enqueues all views not associated with the provided set of keys for reuse.
    /// This method is useful for batch-enqueuing views that are no longer needed.
    ///
    /// - Parameter keys: A set of keys whose associated views should not be enqueued.
    public func enqueueViews(notInSet keys: Set<Key>) {
        Set(usedViews.keys).subtracting(keys).forEach(enqueueView(forKey:))
    }

    /// Enqueues all views associated with the provided set of keys.
    /// This method is useful for batch-enqueuing views that are no longer needed.
    ///
    /// - Parameter keys: A set of keys whose associated views should be enqueued.
    public func enqueueViews(in keys: Set<Key>) {
        keys.forEach(enqueueView(forKey:))
    }

    /// Deinitializes the view reuse queue and clears all stored views.
    deinit {
        queuedViews.removeAll()
        usedViews.removeAll()
    }
}
