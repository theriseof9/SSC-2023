//
//  Edge.swift
//  SSC
//
//  Created by Zerui Wang on 13/4/23.
//

import Foundation

/// A connection between 2 vertices
class Edge<String: Hashable>: Hashable, Equatable {
    typealias T = String
    var source: Vertex<T>
    var destination: Vertex<T>

    func hash(into hasher: inout Hasher) {
        hasher.combine(source)
        hasher.combine(destination)
    }

    init(source: Vertex<T>, destination: Vertex<T>) {
        self.source = source
        self.destination = destination
    }

    static func == (lhs: Edge, rhs: Edge) -> Bool { return lhs.source == rhs.source && lhs.destination == rhs.destination }
}
