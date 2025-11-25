//
//  UploadComponentShape.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct UploadComponentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.73213*width, y: 0.05179*height))
        path.addCurve(to: CGPoint(x: 0.92346*width, y: 0.11218*height), control1: CGPoint(x: 0.8331*width, y: 0.05262*height), control2: CGPoint(x: 0.88779*width, y: 0.05926*height))
        path.addCurve(to: CGPoint(x: 0.96425*width, y: 0.46489*height), control1: CGPoint(x: 0.96425*width, y: 0.1727*height), control2: CGPoint(x: 0.96425*width, y: 0.2701*height))
        path.addLine(to: CGPoint(x: 0.96425*width, y: 0.53376*height))
        path.addCurve(to: CGPoint(x: 0.92346*width, y: 0.88647*height), control1: CGPoint(x: 0.96425*width, y: 0.72855*height), control2: CGPoint(x: 0.96425*width, y: 0.82596*height))
        path.addCurve(to: CGPoint(x: 0.6857*width, y: 0.94698*height), control1: CGPoint(x: 0.88266*width, y: 0.94698*height), control2: CGPoint(x: 0.81701*width, y: 0.94698*height))
        path.addLine(to: CGPoint(x: 0.3143*width, y: 0.94698*height))
        path.addCurve(to: CGPoint(x: 0.07654*width, y: 0.88647*height), control1: CGPoint(x: 0.18299*width, y: 0.94698*height), control2: CGPoint(x: 0.11733*width, y: 0.94698*height))
        path.addCurve(to: CGPoint(x: 0.03575*width, y: 0.53376*height), control1: CGPoint(x: 0.03575*width, y: 0.82596*height), control2: CGPoint(x: 0.03575*width, y: 0.72855*height))
        path.addLine(to: CGPoint(x: 0.03575*width, y: 0.46489*height))
        path.addCurve(to: CGPoint(x: 0.07654*width, y: 0.11218*height), control1: CGPoint(x: 0.03575*width, y: 0.2701*height), control2: CGPoint(x: 0.03575*width, y: 0.1727*height))
        path.addCurve(to: CGPoint(x: 0.26787*width, y: 0.05179*height), control1: CGPoint(x: 0.11221*width, y: 0.05926*height), control2: CGPoint(x: 0.1669*width, y: 0.05262*height))
        return path
    }
}
