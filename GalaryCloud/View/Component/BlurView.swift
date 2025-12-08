//
//  BlurView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 29.11.2025.
//

import SwiftUI
import UIKit

#if !os(watchOS)
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .init(rawValue: -1000)!
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        for _ in 0..<3 {
            let blur = blurView
            view.addSubview(blur)
            addConstraints(blur)
        }
        return view
    }
    
    private var blurView: UIVisualEffectView {
        let effect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: effect)
        let vibracity = UIVisualEffectView(effect: effect)
        view.contentView.addSubview(vibracity)
        addConstraints(vibracity)
        return view
    }
    
    private func addConstraints(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.superview!.trailingAnchor),
            view.topAnchor.constraint(equalTo: view.superview!.topAnchor),
            view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor)
        ])
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
#endif
