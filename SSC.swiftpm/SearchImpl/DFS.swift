//
//  DFS.swift
//  SSC
//
//  Created by Zerui Wang on 13/4/23.
//

import Foundation

extension AdjacencyList { // DFS Extension
    /// Run a depth-first-search from a certain ``Vertex``
    func depthFirstSearch(from source: Vertex<T>) {
        var stack = Stack<Vertex<T>>()
        stack.push(source)
        var visited = Set<Vertex<T>>()
        while let vertex = stack.pop() {
            if !visited.contains(vertex) {
                visited.insert(vertex)
                print(vertex.value)
                adjacencyDict[vertex]?.forEach { edge in
                    stack.push(edge.destination)
                }
            }
        }
    }
}
