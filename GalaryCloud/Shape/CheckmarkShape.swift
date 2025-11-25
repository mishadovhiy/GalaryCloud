//
//  CheckmarkShape.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.89925*width, y: 0.23095*height))
        path.addCurve(to: CGPoint(x: 0.89925*width, y: 0.28988*height), control1: CGPoint(x: 0.91553*width, y: 0.24723*height), control2: CGPoint(x: 0.91553*width, y: 0.27361*height))
        path.addLine(to: CGPoint(x: 0.42719*width, y: 0.76195*height))
        path.addCurve(to: CGPoint(x: 0.36853*width, y: 0.76221*height), control1: CGPoint(x: 0.41102*width, y: 0.77811*height), control2: CGPoint(x: 0.38484*width, y: 0.77823*height))
        path.addLine(to: CGPoint(x: 0.0958*width, y: 0.49435*height))
        path.addCurve(to: CGPoint(x: 0.09527*width, y: 0.43543*height), control1: CGPoint(x: 0.07939*width, y: 0.47822*height), control2: CGPoint(x: 0.07915*width, y: 0.45185*height))
        path.addCurve(to: CGPoint(x: 0.1542*width, y: 0.4349*height), control1: CGPoint(x: 0.1114*width, y: 0.41901*height), control2: CGPoint(x: 0.13778*width, y: 0.41877*height))
        path.addLine(to: CGPoint(x: 0.39746*width, y: 0.67382*height))
        path.addLine(to: CGPoint(x: 0.84033*width, y: 0.23095*height))
        path.addCurve(to: CGPoint(x: 0.89925*width, y: 0.23095*height), control1: CGPoint(x: 0.8566*width, y: 0.21468*height), control2: CGPoint(x: 0.88298*width, y: 0.21468*height))
        path.closeSubpath()
        return path
    }
}
