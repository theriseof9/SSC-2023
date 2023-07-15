//
//  GraphView.swift
//  SSC
//
//  Created by Zerui Wang on 16/4/23.
//

import SwiftUI

@available(iOS 16.0, *)
fileprivate struct GraphNodeView: View {
    @EnvironmentObject private var viewModel: GraphViewModel
    @EnvironmentObject private var provider: WalkthroughProvider

    @AppStorage("userDefinedNames") var userDefinedNames = false

    let idx: Int
    let node: GraphViewModel.NodeType
    let viewportSize: CGSize
    let offset: GestureState<CGSize>
    let onBeforeDelete: GraphView.NodeActionListener?
    let onBfsStart: GraphView.NodeActionListener!
    let onDfsStart: GraphView.NodeActionListener!
    let onLink: (Edge<String>) -> Void

    @State private var popoverPresented = false

    var body: some View {
        let pos = node.pos.toAbsolutePos(viewportSize: viewportSize)

        Circle()
            .fill(node.state == .visited ? .green : node.state == .pending ? .blue : .gray)
            .frame(width: node.rad*2, height: node.rad*2)
            .overlay {
                // if popoverPresented { Text(node.backingVertex.value) }
            }
            .contextMenu {
                
                Text(userDefinedNames ? node.backingVertex.value : "Vertex (Node)")
                Button() {
                    _ = onDfsStart(node.backingVertex)
                } label: {
                    Label("Start DFS", systemImage: "play")
                }.disabled(provider.currentStep < 4)
                
                Button() {
                    print("Starting BFS")
                    _ = onBfsStart(node.backingVertex)
                } label: {
                    Label("Start BFS", systemImage: "play")
                }.disabled(provider.currentStep < 5)
                
                Button(role: .destructive) {
                    if let onBeforeDelete {
                        withAnimation {
                            _ = onBeforeDelete(node.backingVertex)
                            // _ = viewModel.removeNode(at: idx)
                            if (provider.currentStep == 3) {
                                provider.nextButtonDisabled = false
                            }
                        }
                    }
                } label: {
                    Label("Remove Vertex", systemImage: "trash")
                }.disabled(provider.currentStep < 3)
            }
            .shadow(color: .black.opacity(0.5), radius: 6)
            .contentShape(Circle())
            .hoverEffect(.lift)
            .position(pos)
            .offset(viewModel.draggingNode == node ? offset.wrappedValue : .zero)
            .animation(.interactiveSpring(), value: viewModel.draggingNode == node)
            .gesture(
                DragGesture()
                    .updating(offset) { newState, offset, _ in
                        offset = newState.translation
                        viewModel.nodeDragUpdate(node: node)
                    }
                    .onEnded { gesture in
                        viewModel.nodeDragEnd(idx: idx, off: gesture.translation, viewportSize: viewportSize, enableCollisionLink: provider.currentStep >= 2, onLink: onLink)
                        if viewModel.links.count != 0 && provider.currentStep == 2 {
                            provider.nextButtonDisabled = false
                        }
                    }
                    .exclusively(before: TapGesture().onEnded {
                        popoverPresented.toggle()
                    })
            )
    }
}

fileprivate struct GraphLinkView: View {
    let srcPt: CGPoint
    let dstPt: CGPoint

    var body: some View {
        Path { p in
            p.move(to: srcPt)
            p.addLine(to: dstPt)
        }
        .stroke(.blue, lineWidth: 4)
        .shadow(color: .black.opacity(0.4), radius: 4)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 100))
        .contextMenu {
            Label("aaa", image: "adbcd")
            Button(role: .destructive) {
                
            } label: {
                Label("Remove Edge", systemImage: "trash")
            }
        }
    }
}

/// Graphs at home:
@available(iOS 16.0, *)
struct GraphView: View {
    @EnvironmentObject private var provider: WalkthroughProvider
    @StateObject private var viewModel = GraphViewModel()

    typealias CanvasTapListener = ((CGPoint, CGSize) -> Void)
    typealias NodeActionListener = ((Vertex<String>) -> Bool)    
    private let onCanvasTap: CanvasTapListener?
    private let onNodeDelete: NodeActionListener?
    private let onBfsStart: NodeActionListener?
    private let onDfsStart: NodeActionListener?
    private let content: [GraphNode]
    private let onLink: (Edge<String>) -> Void

    
    init(@GraphContentBuilder content: () -> [GraphNode], onCanvasTap: CanvasTapListener? = nil, onNodeDelete: NodeActionListener? = nil, onBfsStart: NodeActionListener? = nil, onDfsStart: NodeActionListener? = nil, onLink: @escaping (Edge<String>) -> Void) {
        self.content = content()
        self.onCanvasTap = onCanvasTap
        self.onNodeDelete = onNodeDelete
        self.onDfsStart = onDfsStart
        self.onBfsStart = onBfsStart
        self.onLink = onLink
        print(onBfsStart!)
    }

    @GestureState private var draggingOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            // Viewport size
            let size = proxy.size
            ZStack(alignment: .topLeading) {
                ForEach(Array(viewModel.nodes.enumerated()), id: \.element) { idx, node in
                    // Check if there should be any conns first - this is to
                    // prevent connections from visually "overlapping" with nodes
                    ForEach(viewModel.links.filter({ $0.src == node.backingVertex }), id: \.hashValue) { link in
                        // Get start and end pos - could be made more efficient with clever use of a Set
                        if let srcNode = viewModel.findNode(for: link.src), let dstNode = viewModel.findNode(for: link.dst) {
                            let srcP = srcNode.pos.toAbsolutePos(viewportSize: size)
                            let dstP = dstNode.pos.toAbsolutePos(viewportSize: size)
                            // Offset starting pos if either node is being
                            GraphLinkView(
                                srcPt: viewModel.draggingNode == srcNode ? .init(x: srcP.x + draggingOffset.width, y: srcP.y + draggingOffset.height) : srcP,
                                dstPt: viewModel.draggingNode == dstNode ? .init(x: dstP.x + draggingOffset.width, y: dstP.y + draggingOffset.height) : dstP
                            )
                            .zIndex(0)
                        }
                    }
                    GraphNodeView(idx: idx, node: node, viewportSize: size, offset: $draggingOffset, onBeforeDelete: onNodeDelete, onBfsStart: onBfsStart, onDfsStart: onDfsStart, onLink: onLink)
                        .environmentObject(viewModel)
                        .zIndex(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { pt in
                if let onCanvasTap { onCanvasTap(pt, size) }
            }
        }
        .onAppear {
            viewModel.updateNodes(newBlocks: content)
        }
        .onChange(of: content) { newContent in
            viewModel.updateNodes(newBlocks: newContent)
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            GraphView {

            } onLink: { _ in
                
            }
        } else {
            EmptyView()
        }
    }
}
