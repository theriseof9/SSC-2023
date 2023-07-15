//
//  SearchUtils.swift
//  SSC
//
//  Created by Zerui Wang on 13/4/23.
//

import Foundation

/// A simple LIFO stack implementation
struct Stack<T> {
    private var array: [T] = []

    /// If there are no elements in the stack
    var isEmpty: Bool { array.isEmpty }

    /// Push an element to the bottom of the stack
    ///
    /// Since this is a LIFO collection, calling ``pop()`` or ``peek()`` will return this element.
    mutating func push(_ element: T) { array.append(element) }
    /// Get and remove the last element stored in this stack
    mutating func pop() -> T? { array.popLast() }

    /// Get the value that will be returned by ``pop()``, without removing it from the stack
    func peek() -> T? { array.last }
}

/// A simple FIFO queue implementation
struct Queue<T> {
    private var array: [T] = []

    /// If there are no elements in the queue
    var isEmpty: Bool { array.isEmpty }

    /// Push an item into the back of the queue
    mutating func enqueue(_ element: T) { array.append(element) }
    /// Return and remove the first item from the queue
    mutating func dequeue() -> T? { isEmpty ? nil : array.removeFirst() }

    /// Get the value that will be returned by ``dequeue()``, without removing it from the queue
    func peek() -> T? { array.first }
}
