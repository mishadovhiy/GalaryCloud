//
//  Arrow.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct ArrowShape: Shape {
    let top: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        if top {
            path.move(to: CGPoint(x: 0.5*width, y: 0.94835 * height))
            path.addLine(to: CGPoint(x: 0.5*width, y: 0.05303*height))
            path.move(to: CGPoint(x: 0.5*width, y: 0.05303*height))
            path.addLine(to: CGPoint(x: 0.9*width, y: 0.29408*height))
            path.move(to: CGPoint(x: 0.5*width, y: 0.05303*height))
            path.addLine(to: CGPoint(x: 0.1*width, y: 0.29408 * height))
        } else {
            path.move(to: CGPoint(x: 0.5*width, y: 0.94835*height))
            path.addLine(to: CGPoint(x: 0.5*width, y: 0.05102*height))
            path.move(to: CGPoint(x: 0.5*width, y: 0.94898*height))
            path.addLine(to: CGPoint(x: 0.9*width, y: 0.69728*height))
            path.move(to: CGPoint(x: 0.5*width, y: 0.94898*height))
            path.addLine(to: CGPoint(x: 0.1*width, y: 0.69728*height))
        }
        return path
    }
}
