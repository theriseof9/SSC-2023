//
//  RelativePos.swift
//  SSC
//
//  Created by Zerui Wang on 14/4/23.
//

import Foundation

struct RelativePos: Hashable {
    let x: CGFloat // Proportional to viewport size
    let y: CGFloat

    func toAbsolutePos(viewportSize: CGSize) -> CGPoint {
        CGPoint(x: x*viewportSize.width, y: y*viewportSize.height)
    }

    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    init(point: CGPoint, parentSize: CGSize) {
        x = point.x / parentSize.width
        y = point.y / parentSize.height
    }

    static let zero: Self = .init(x: 0, y: 0)
}
