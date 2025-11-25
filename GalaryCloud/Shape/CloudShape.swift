//
//  CloudShape.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.96467*width, y: 0.64142*height))
        path.addCurve(to: CGPoint(x: 0.80195*width, y: 0.94225*height), control1: CGPoint(x: 0.96467*width, y: 0.77676*height), control2: CGPoint(x: 0.89755*width, y: 0.89287*height))
        path.move(to: CGPoint(x: 0.61046*width, y: 0.33375*height))
        path.addCurve(to: CGPoint(x: 0.69901*width, y: 0.31519*height), control1: CGPoint(x: 0.63815*width, y: 0.32173*height), control2: CGPoint(x: 0.66796*width, y: 0.31519*height))
        path.addCurve(to: CGPoint(x: 0.78592*width, y: 0.33304*height), control1: CGPoint(x: 0.72945*width, y: 0.31519*height), control2: CGPoint(x: 0.75868*width, y: 0.32147*height))
        path.move(to: CGPoint(x: 0.27272*width, y: 0.48289*height))
        path.addCurve(to: CGPoint(x: 0.23411*width, y: 0.4783*height), control1: CGPoint(x: 0.26023*width, y: 0.47988*height), control2: CGPoint(x: 0.24732*width, y: 0.4783*height))
        path.addCurve(to: CGPoint(x: 0.03487*width, y: 0.72298*height), control1: CGPoint(x: 0.12407*width, y: 0.4783*height), control2: CGPoint(x: 0.03487*width, y: 0.58785*height))
        path.addCurve(to: CGPoint(x: 0.17434*width, y: 0.95645*height), control1: CGPoint(x: 0.03487*width, y: 0.83253*height), control2: CGPoint(x: 0.0935*width, y: 0.92527*height))
        path.move(to: CGPoint(x: 0.27272*width, y: 0.48289*height))
        path.addCurve(to: CGPoint(x: 0.25625*width, y: 0.36956*height), control1: CGPoint(x: 0.26207*width, y: 0.44759*height), control2: CGPoint(x: 0.25625*width, y: 0.40941*height))
        path.addCurve(to: CGPoint(x: 0.52191*width, y: 0.04333*height), control1: CGPoint(x: 0.25625*width, y: 0.18939*height), control2: CGPoint(x: 0.37519*width, y: 0.04333*height))
        path.addCurve(to: CGPoint(x: 0.78592*width, y: 0.33304*height), control1: CGPoint(x: 0.65857*width, y: 0.04333*height), control2: CGPoint(x: 0.77113*width, y: 0.17006*height))
        path.move(to: CGPoint(x: 0.27272*width, y: 0.48289*height))
        path.addCurve(to: CGPoint(x: 0.3448*width, y: 0.5195*height), control1: CGPoint(x: 0.29896*width, y: 0.48922*height), control2: CGPoint(x: 0.32335*width, y: 0.50187*height))
        path.move(to: CGPoint(x: 0.78592*width, y: 0.33304*height))
        path.addCurve(to: CGPoint(x: 0.89323*width, y: 0.41883*height), control1: CGPoint(x: 0.82727*width, y: 0.35062*height), control2: CGPoint(x: 0.86399*width, y: 0.38038*height))
        return path
    }
}
