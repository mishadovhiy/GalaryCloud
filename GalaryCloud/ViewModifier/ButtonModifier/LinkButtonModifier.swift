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
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(background)
            .cornerRadius(8)
            .tint(tint)
            .font(.system(size: 12, weight: .medium))
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
