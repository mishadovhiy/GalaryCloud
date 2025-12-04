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
                .font(.title)
                .foregroundColor(.primaryText)
                .minimumScaleFactor(0.3)
            Spacer().frame(height: 15)
            if message.buttons.isEmpty {
                Button("ok") {
                    dismiss()
                }
                .modifier(LinkButtonModifier(type: .default))
            } else {
                if message.buttons.count <= 2 {
                    HStack(spacing: 20) {
                        buttonsView
                    }
                } else {
                    VStack(spacing: 20) {
                        buttonsView
                    }
                }
                
            }
        }
        .navigationTitle(message.header)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ClearBackgroundView()
        }
        .background(.primaryContainer)
    }
    
    var buttonsView: some View {
        ForEach(message.buttons, id: \.title) { button in
            Button(button.title) {
                dismiss()
                button.didPress?()
            }
            .modifier(LinkButtonModifier(type: button.type))
        }
    }
}
