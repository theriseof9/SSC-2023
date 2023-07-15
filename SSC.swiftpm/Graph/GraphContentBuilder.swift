//
//  GraphContentBuilder.swift
//  SSC
//
//  Created by Zerui Wang on 16/4/23.
//

import Foundation

@resultBuilder
struct GraphContentBuilder {
    static func buildBlock(_ components: [GraphNode]...) -> [GraphNode] {
        Array(components.joined())
    }

    static func buildExpression(_ expression: GraphNode) -> [GraphNode] {
        [expression]
    }

    static func buildArray(_ components: [[GraphNode]]) -> [GraphNode] {
        Array(components.joined())
    }
}
