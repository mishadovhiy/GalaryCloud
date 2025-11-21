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
                        .onChange(of: proxy.size.debugDescription) { _ in
                            viewSize?.wrappedValue = proxy.size
                        }
                        .onChange(of: proxy.safeAreaInsets) { _ in
                            safeArea?.wrappedValue = proxy.safeAreaInsets
                        }
                        .onChange(of: proxy.frame(in: .global).origin) { _ in
                            position?.wrappedValue = proxy.frame(in: .global).origin

                        }
                }
            }
    }
}

