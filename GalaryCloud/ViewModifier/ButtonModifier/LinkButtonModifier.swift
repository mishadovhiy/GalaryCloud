//
//  LinkButtonModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import SwiftUI

struct LinkButtonModifier: ViewModifier {
    
    var disctructive = false
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(disctructive ? .primaryText.opacity(0.15) : .red.opacity(0.15))
            .cornerRadius(8)
            .tint(disctructive ? .red : .black)
            .font(.system(size: 12, weight: .medium))
    }
}
