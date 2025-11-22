//
//  AlertModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 22.11.2025.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    
    @Binding var messages: [MessageModel]
    
    func body(content: Content) -> some View {
        content
            .overlay {
                VStack {
                    Spacer()
                    alertView
                    
                }
            }
        
    }
    
    @ViewBuilder
    var alertView: some View {
        let currentAlert = messages.last
        if currentAlert != nil {
            VStack {
                Text("alert")
                Text(currentAlert?.title ?? "")
                Spacer().frame(height: 10)
                VStack(spacing: 20) {
                    if currentAlert?.buttons.isEmpty ?? true {
                        Button("OK") {
                            isPresented.wrappedValue = false
                        }
                    } else {
                        ForEach(currentAlert?.buttons ?? [], id: \.title) { buttonModel in
                            Button(buttonModel.title) {
                                buttonModel.didPress?()
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 20)
            .background(.red)
        }
    }
    
    var isPresented: Binding<Bool> {
        .init {
            !messages.isEmpty
        } set: {
            if !$0 {
                messages.removeLast()
            }
        }
    }
    
}
