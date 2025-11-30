//
//  MessageStaticView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 30.11.2025.
//

import SwiftUI

struct MessageStaticView: View {
    
    let message: MessageModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Text(message.title)
            if message.buttons.isEmpty {
                Button("ok") {
                    dismiss()
                }
            } else {
                ForEach(message.buttons, id: \.title) { button in
                    Button(button.title) {
                        dismiss()
                        button.didPress?()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ClearBackgroundView()
        }
        .background(.primaryContainer)
    }
}
