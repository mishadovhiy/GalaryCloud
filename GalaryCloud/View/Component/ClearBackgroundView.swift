//
//  ClearBackgroundView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import SwiftUI

#if os(watchOS)
struct ClearBackgroundView: View {
    var body: some View {
        Color.clear
    }
}
#else
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
            view.superview?.backgroundColor = .clear
            view.backgroundColor = .clear

            view.superview?.superview?.superview?.backgroundColor = .clear

        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
            uiView.superview?.backgroundColor = .clear
            uiView.backgroundColor = .clear

            uiView.superview?.superview?.superview?.backgroundColor = .clear

        }
        
    }
}
#endif
