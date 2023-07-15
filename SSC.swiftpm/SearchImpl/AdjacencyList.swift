//
//  AdjacencyList.swift
//  SSC
//
//  Created by Zerui Wang on 13/4/23.
//

import Foundation

class AdjacencyList<String: Hashable> {
    typealias T = String
    
    var adjacencyDict: [Vertex<T>: [Edge<T>]] = [:]

    func createVertex(value: T) -> Vertex<T> {
        if let vertex = adjacencyDict.keys.first(where: { $0.value == value }) { return vertex }
        else {
            let vertex = Vertex(value: value)
            adjacencyDict[vertex] = []
            return vertex
        }
    }

    func deleteVertex(vertex: Vertex<T>) {
        for edge in adjacencyDict[vertex] ?? [] {
            deleteEdge(source: edge.source, destination: edge.destination)
        }
        adjacencyDict.removeValue(forKey: vertex)
    }

    func addEdge(source: Vertex<T>, destination: Vertex<T>) {
        let edge = Edge(source: source, destination: destination)
        if (adjacencyDict[source]?.first(where: {$0.destination == destination})) == nil {
            adjacencyDict[source]?.append(edge)
            print("Added")
        }
        if (adjacencyDict[destination]?.first(where: { $0.destination == source })) == nil {
            let reverseEdge = Edge(source: destination, destination: source)
            adjacencyDict[destination]?.append(reverseEdge)
            print("Added")
        }
    }
    
    func addEdge(edge: Edge<T>) {
        addEdge(source: edge.source, destination: edge.destination)
    }

    func deleteEdge(source: Vertex<T>, destination: Vertex<T>) {
        if let index = adjacencyDict[source]?.firstIndex(where: { $0.destination == destination }) {
            adjacencyDict[source]?.remove(at: index)
        }
        if let index = adjacencyDict[destination]?.firstIndex(where: { $0.destination == source }) {
            adjacencyDict[destination]?.remove(at: index)
        }
    }
}
