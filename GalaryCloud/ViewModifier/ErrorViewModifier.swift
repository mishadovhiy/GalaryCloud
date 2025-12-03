//
//  ErrorViewModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 03.12.2025.
//

import SwiftUI

struct ErrorViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.red)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.red.opacity(0.15))
            .cornerRadius(8)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.red, lineWidth: 1)
            }
            .padding(.horizontal, 10)
    }
}
