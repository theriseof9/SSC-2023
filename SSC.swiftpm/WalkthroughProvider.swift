//
//  WalkthroughProvider.swift
//  SSC
//
//  Created by Zerui Wang on 12/4/23.
//

import SwiftUI

@available(iOS 16.0, *)
class WalkthroughProvider: ObservableObject {
    @Published var steps: [WalkthroughStep] = []
    @Published var currentStep: Int = 0
    @Published var nextButtonDisabled = false
    
    init() {
        loadSteps()
    }
    
    func loadSteps() {
        steps = [
            WalkthroughStep(title: "Welcome", description: "Welcome to my app for SSC! Lets learn some basic controls first, the next button will be enabled when you perform the action."),
            WalkthroughStep(title: "Add Nodes", description: "A node is considered as a point in the graph, which could be similar to a person in a social network. Tap anywhere on the canvas to add a node. Add at least 2 nodes to continue."),
            WalkthroughStep(title: "Connect Nodes", description: "Drag from one node to another to create an edge. An edge is considered to be a 'connection' between 2 nodes, which is similar to a 'connection' on social media platforms such as linkedin."),
            WalkthroughStep(title: "Modify Nodes", description: "Long press on a node to delete it, or drag on a node to change its position. Delete a node to continue."),
            WalkthroughStep(title: "DFS", description: "DFS, also known as depth first search, is an algorithm that searches a graph by exploring as far as possible along each branch before backtracking and going to other nodes. Start a simulation by long clicking on any node! Start a DFS with at least 4 edges (lines) connected to continue."),
            WalkthroughStep(title: "BFS", description: "BFS, also known as breadth first search, is an algorithm to search graph by traversing all its nodes. Unlike DFS, it visits nodes at the same depth before visiting nodes of the next depth. Start a simulation by long clicking on any node!"),
            WalkthroughStep(title: "Done", description: "You have completed the walkthrough. Enjoy the app! No asse"),
        ]
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
            nextButtonDisabled = true
        } else {
            currentStep = 0
        }
    }
}

struct WalkthroughStep {
    var title: String
    var description: String
}
