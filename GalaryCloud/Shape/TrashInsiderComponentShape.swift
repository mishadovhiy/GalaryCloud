//
//  TrashInsiderComponentShape.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct TrashInsiderComponentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.9223*width, y: 0.06479*height))
        path.addLine(to: CGPoint(x: 0.9223*width, y: 0.93662*height))
        path.addLine(to: CGPoint(x: 0.9223*width, y: 0.06479*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0.06479*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.93662*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.06479*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.0777*width, y: 0.06479*height))
        path.addLine(to: CGPoint(x: 0.0777*width, y: 0.93662*height))
        path.addLine(to: CGPoint(x: 0.0777*width, y: 0.06479*height))
        path.closeSubpath()
        return path
    }
}
