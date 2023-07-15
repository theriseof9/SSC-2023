//
//  Vertex.swift
//  SSC
//
//  Created by Zerui Wang on 13/4/23.
//

import Foundation

/// A node in the BFS/DFS tree
class Vertex<T: Hashable>: Hashable, Equatable, Identifiable {
    var value: T

    var id: T { value }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    init(value: T) { self.value = value }

    static func == (lhs: Vertex, rhs: Vertex) -> Bool { return lhs.value == rhs.value }
}
