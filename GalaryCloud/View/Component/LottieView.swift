//
//  LottieView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import UIKit
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        let animationView: LottieAnimationView = .init(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        animationView.animationSpeed = 0.5
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: animationView.superview!.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: animationView.superview!.heightAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
