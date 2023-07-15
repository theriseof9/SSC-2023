//
//  GraphNode.swift
//  SSC
//
//  Created by Zerui Wang on 16/4/23.
//

import Foundation

struct GraphNode: Equatable {
    let vertex: Vertex<String>
    var conns: [Edge<String>] = []
    let initialPos: RelativePos
    let state: VisitedState

    init(vertex: Vertex<String>, initialPos: RelativePos = .zero, state: VisitedState = .notVisited) {
        self.vertex = vertex
        self.initialPos = initialPos
        self.state = state
    }

    func connect(to dst: Vertex<String>) -> Self {
        var d = self // Only mutate a copy
        d.conns.append(.init(source: vertex, destination: dst))
        return d
    }
}


enum VisitedState {
    case visited
    case pending
    case notVisited
}
