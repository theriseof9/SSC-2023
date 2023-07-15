import SwiftUI

@available(iOS 16.0, *)
struct ContentView: View {
    @ObservedObject private var provider = WalkthroughProvider()

    @State private var nodes: [(vertex: Vertex<String>, initialPos: RelativePos, state: VisitedState)] = []

    @AppStorage("userDefinedNames") var userDefinedNames = false

    @State private var addNodePresented = false
    @State private var newNodeName = ""
    @State private var addingPos: RelativePos?
    @State private var simulationSpeed: Float = 1.0

    private var adjacencyList: AdjacencyList<String> = AdjacencyList()

    private static let simQueue = DispatchQueue(label: "simQueue", qos: .userInitiated, target: .global())

    // @State private var nodes: [GraphNode]

    var body: some View {
        NavigationSplitView {
            List {
                WalkthroughStepView(step: provider.steps[provider.currentStep], simulationSpeed: $simulationSpeed)
                    .navigationBarBackButtonHidden(true)
            }
        } detail: {
            GraphView {
                for n in nodes {
                    GraphNode(vertex: n.vertex, initialPos: n.initialPos, state: n.state)
                }
                /*GraphNode(vertex: .init(value: "test 2"))
                    .connect(to: .init(value: "test 3"))
                GraphNode(vertex: .init(value: "test 3"))
                GraphNode(vertex: .init(value: "test 4"))
                    .connect(to: .init(value: "test 2"))
                GraphNode(vertex: .init(value: "test 5"))
                    .connect(to: .init(value: "test 4"))
                    .connect(to: .init(value: "test 2"))*/
            } onCanvasTap: { pt, viewboxSize in
                if (provider.currentStep < 1) {
                    return
                }
                print("tap \(pt)")
                let pt = RelativePos(point: pt, parentSize: viewboxSize)
                if userDefinedNames {
                    addingPos = pt
                    addNodePresented = true
                } else {
                    withAnimation {
                        let uuid = UUID().uuidString
                        nodes.append((.init(value: uuid), pt, .notVisited))
                        _ = adjacencyList.createVertex(value: uuid)
                        if provider.currentStep == 1 {
                            provider.nextButtonDisabled = !(nodes.count >= 2)
                        }
                    }
                }
                // nodes.append("\(pt.x):\(pt.y)")
            } onNodeDelete: { vertex in
                nodes.removeAll { $0.vertex == vertex }
                adjacencyList.deleteVertex(vertex: vertex)
                return true // Always allow delete
            } onBfsStart: { vertex in
                resetNodes()
                print("Bfs started")
                Self.simQueue.async {
                    var queue = Queue<Vertex<String>>()
                    queue.enqueue(vertex)
                    var visited = Set<Vertex<String>>()
                    while let vertex = queue.dequeue() {
                        print("BFS")
                        if !visited.contains(vertex) {
                            print(vertex)
                            nodes[nodes.firstIndex(where: {$0.vertex.value == vertex.value})!].state = .visited
                            visited.insert(vertex)
                            print(vertex.value)
                            adjacencyList.adjacencyDict[vertex]?.forEach { edge in
                                if !visited.contains(edge.destination) {
                                    queue.enqueue(edge.destination)
                                    nodes[nodes.firstIndex(where: {$0.vertex.value == edge.destination.value})!].state = .pending
                                }
                            }
                        }
                        usleep(1000000*UInt32(simulationSpeed))
                    }
                }
                return true
            } onDfsStart: { vertex in
                resetNodes()
                provider.nextButtonDisabled = false
                Self.simQueue.async {
                    var stack = Stack<Vertex<String>>()
                    stack.push(vertex)
                    var visited = Set<Vertex<String>>()
                    while let vertex = stack.pop() {
                        if !visited.contains(vertex) {
                            visited.insert(vertex)
                            print(vertex.value)
                            nodes[nodes.firstIndex(where: {$0.vertex.value == vertex.value})!].state = .visited
                            adjacencyList.adjacencyDict[vertex]?.forEach { edge in
                                if !visited.contains(edge.destination) {
                                    stack.push(edge.destination)
                                    nodes[nodes.firstIndex(where: {$0.vertex.value == edge.destination.value})!].state = .pending
                                }
                            }
                        }
                        usleep(1000000*UInt32(simulationSpeed))
                    }
                }
                return true
            } onLink: { edge in
                adjacencyList.addEdge(edge: edge)
            }
            .background {
                if nodes.isEmpty {
                    Text("Tap anywhere to add a node!").transition(.opacity)
                }
            }
            .environmentObject(provider)
        }
        .navigationSplitViewStyle(.balanced)
        .environmentObject(provider)
        .alert("Add Node", isPresented: $addNodePresented, actions: {
            // Any view other than Button would be ignored
            TextField("Name", text: $newNodeName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                nodes.append((.init(value: newNodeName), addingPos ?? .zero, .notVisited))
                newNodeName = ""
            }
        }, message: {
            // Any view other than Text would be ignored
            // Text("Abcd")
        })
    }
    
    func resetNodes() {
        for i in nodes.indices {
            nodes[i].state = .notVisited
        }
    }
}
