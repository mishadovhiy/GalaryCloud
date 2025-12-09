//
//  LinkButtonModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import SwiftUI

struct LinkButtonModifier: ViewModifier {
    
    var type: Type = .default
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(background)
            .cornerRadius(12)
            .tint(tint)
            .font(.system(size: 13, weight: .medium))
            .minimumScaleFactor(0.2)
    }
    
    private var background: Color {
        switch type {
        case .default: .primaryText
        default: tint.opacity(0.15)
        }
    }
    
    private var tint: Color {
        switch type {
        case .link: .blue
        case .distructive: .red
        case .default: .primaryContainer
        }
    }
    
    enum `Type` {
        case distructive
        case `default`
        case link
    }
}
