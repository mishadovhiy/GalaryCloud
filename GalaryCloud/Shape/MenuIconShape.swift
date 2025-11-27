//
//  MenuIconShape.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import SwiftUI

struct MenuIconShape: Shape {
    var type: `Type`

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        switch type {
        case .close:
            path.move(to: CGPoint(x: 0.025*width, y: 0.03333*height))
            path.addLine(to: CGPoint(x: 0.8*width, y: 0.83333*height))
            path.move(to: CGPoint(x: 0.82991*width, y: 0.03333*height))
            path.addLine(to: CGPoint(x: 0.0619*width, y: 0.8*height))
        case .menu:
            path.move(to: CGPoint(x: 0.02174*width, y: 0.03333*height))
            path.addLine(to: CGPoint(x: 0.8913*width, y: 0.03333*height))
            path.move(to: CGPoint(x: 0.02174*width, y: 0.43333*height))
            path.addLine(to: CGPoint(x: 0.47826*width, y: 0.43333*height))
            path.move(to: CGPoint(x: 0.02174*width, y: 0.83333*height))
            path.addLine(to: CGPoint(x: 0.69565*width, y: 0.83333*height))
        }
        return path
    }
}

extension MenuIconShape {
    enum `Type` { case menu, close }
}
