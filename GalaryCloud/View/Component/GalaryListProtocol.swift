//
//  GalaryListProtocol.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 09.12.2025.
//

import SwiftUI

protocol GalaryListProtocol { }

extension View where Self: GalaryListProtocol {
    var selectionIndicator: some View {
        VStack(alignment: .leading) {
            HStack {
                Color.red
                    .frame(maxWidth: 10, maxHeight: 10, alignment: .leading)
                    .cornerRadius(5)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .frame(alignment: .leading)
        .padding(5)
        .allowsHitTesting(false)
        .disabled(true)
    }
}
