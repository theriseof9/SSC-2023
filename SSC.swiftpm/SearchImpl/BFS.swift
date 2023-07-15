//
//  BFS.swift
//  SSC
//
//  Created by Zerui Wang on 13/4/23.
//

import Foundation

extension AdjacencyList { // BFS Extension
    /// Run a breadth-first-search from a certain ``Vertex``
    func breadthFirstSearch(from source: Vertex<T>) {
        var queue = Queue<Vertex<T>>()
        queue.enqueue(source)
        var visited = Set<Vertex<T>>()
        while let vertex = queue.dequeue() {
            if !visited.contains(vertex) {
                visited.insert(vertex)
                print(vertex.value)
                adjacencyDict[vertex]?.forEach { edge in
                    queue.enqueue(edge.destination)
                }
            }
        }
    }
}
