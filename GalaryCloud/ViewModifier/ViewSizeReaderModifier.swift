//
//  ViewSizeReaderModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct ViewSizeReaderModifier: ViewModifier {
    var viewSize: Binding<CGSize>?
    var safeArea: Binding<EdgeInsets>?
    var position: Binding<CGPoint>?

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            viewSize?.wrappedValue = proxy.size
                            safeArea?.wrappedValue = proxy.safeAreaInsets
                            position?.wrappedValue = proxy.frame(in: .global).origin
                        }
                        .modifier(ValueModifier(value: position == nil ? nil : proxy.frame(in: .global).origin, didChange: { newValue in
                            position?.wrappedValue = proxy.frame(in: .global).origin
                        }))
                        .modifier(ValueModifier(value: safeArea == nil ? nil : proxy.safeAreaInsets, didChange: { newValue in
                            safeArea?.wrappedValue = proxy.safeAreaInsets
                        }))
                        .modifier(ValueModifier(value: viewSize == nil ? nil : proxy.size, didChange: { newValue in
                            viewSize?.wrappedValue = proxy.size
                        }))
                }
            }
    }
}

fileprivate struct ValueModifier<T: Equatable>: ViewModifier {
    let value: T?
    let didChange: (_ newValue: T) -> ()
    
    func body(content: Content) -> some View {
        if let value {
            content
                .onChange(of: value) { newValue in
                    didChange(newValue)
                }
        } else {
            content
        }
    }
}
