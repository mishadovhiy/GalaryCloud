//
//  SignInWithAppleButton.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import UIKit
import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: UIViewRepresentable {
    var action: () -> Void

    func makeUIView(context: Context) -> UIView {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(context.coordinator,
                         action: #selector(Coordinator.tapped),
                         for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func tapped() {
            action()
        }
    }
}
