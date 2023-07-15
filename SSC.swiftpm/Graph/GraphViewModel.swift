//
//  GraphViewModel.swift
//  SSC
//
//  Created by Zerui Wang on 16/4/23.
//

import SwiftUI

@MainActor class GraphViewModel: ObservableObject {
    typealias NodeType = Node<String>
    typealias LinkType = Link<String>

    /// Configuration for a node, represented as a circle
    struct Node<T: Hashable>: Hashable, Equatable {
        // var id: Int { backingVertex.hashValue ^ pos.hashValue }

        func hash(into hasher: inout Hasher) {
            hasher.combine(backingVertex)
        }

        let pos: RelativePos
        /// Radius of node circle
        let rad: Double
        let backingVertex: Vertex<T>
        let state: VisitedState

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.backingVertex == rhs.backingVertex }

        func move(to newRelative: RelativePos) -> Self {
            .init(pos: newRelative, rad: rad, backingVertex: backingVertex, state: state)
        }

        func collides(with node: Node, nodePos: CGPoint, portSize: CGSize) -> Bool {
            // Basically just check if the node dist is < self.rad + node.rad
            let thisPos = pos.toAbsolutePos(viewportSize: portSize)
            return sqrt(pow(thisPos.x-nodePos.x, 2) + pow(thisPos.y-nodePos.y, 2)) < (node.rad+rad)
        }
    }

    /// A connection (``Edge``) between 2 vertices
    struct Link<T: Hashable>: Hashable, Equatable {
        let src: Vertex<T>
        let dst: Vertex<T>

        init(edge: Edge<T>) {
            src = edge.source
            dst = edge.destination
        }
        init(src: Vertex<T>, dst: Vertex<T>) {
            self.src = src
            self.dst = dst
        }
    }

    @Published var nodes: [NodeType] = []
    @Published var links = Set<LinkType>()
    @Published var draggingNode: NodeType?
    @Published var popoverItem: Vertex<String>?
    
    func updateNodes(newBlocks: [GraphNode]) {
            // This should probably be cleaned up but ehhh
            nodes = newBlocks.compactMap { block in
                // Preserve location
                let oldNode = nodes.first(where: { $0.backingVertex == block.vertex })
                if oldNode == nil { block.conns.forEach { edge in
                    links.insert(.init(edge: edge))
                }}
                return Node<String>(
                    pos: oldNode?.pos ?? block.initialPos, rad: oldNode?.rad ?? 25,
                    backingVertex: block.vertex,
                    state: block.state
                )
            }
        }
}

// MARK: - Node Ops
extension GraphViewModel {
    func findNode(for vertex: Vertex<String>) -> NodeType? {
        nodes.first { $0.backingVertex == vertex }
    }

    @discardableResult func removeNode(at idx: Int) -> NodeType {
        let n = nodes.remove(at: idx)
        // Remove all links to/from this node
        links.remove(.init(src: n.backingVertex, dst: n.backingVertex))
        // links.removeAll { $0.src == n.backingVertex || $0.dst == n.backingVertex }
        return n
    }
}

// MARK: - Node mutation
extension GraphViewModel {
    func nodeDragUpdate(node: NodeType) {
        DispatchQueue.main.async { [weak self] in
            self?.draggingNode = node
        }
    }

    func nodeDragEnd(idx: Int, off: CGSize, viewportSize: CGSize, enableCollisionLink: Bool, onLink: (Edge<String>) -> Void) {
        let node = nodes[idx]
        let oldPos = node.pos.toAbsolutePos(viewportSize: viewportSize)
        let newLoc = CGPoint(x: oldPos.x+off.width, y: oldPos.y+off.height)

        defer { draggingNode = nil } // We are done dragging

        // Ensure the node isn't dragged out of the canvas
        guard newLoc.x > node.rad, newLoc.x+node.rad < viewportSize.width,
              newLoc.y > node.rad, newLoc.y+node.rad < viewportSize.height else {
            print("Node dragged out of canvas, not committing")
            return // Dragged out of bounds
        }

        // Check collisions
        if let collidingNode = nodes.first(where: { $0 != node && $0.collides(with: node, nodePos: newLoc, portSize: viewportSize) }) {
            // Make a link to this node instead
            print("Make link to: \(collidingNode.backingVertex.value)")
            let edge = Edge(source: node.backingVertex, destination: collidingNode.backingVertex)
            let newLink = Link(edge: edge)
            // Make sure the link doesn't already exist
            guard !(links.contains(newLink) || !enableCollisionLink) else {
                print("Link already exists")
                return
            }
            links.insert(newLink)
            onLink(edge)
            return
        }
        print("dragging off: \(off)")
        nodes[idx] = node.move(to: .init(point: newLoc, parentSize: viewportSize))
        print("set pos: \(nodes[idx].pos.toAbsolutePos(viewportSize: viewportSize))")
    }
}
