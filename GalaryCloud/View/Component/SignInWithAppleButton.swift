//
//  SignInWithAppleButton.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import UIKit
import SwiftUI
import AuthenticationServices

#if !os(watchOS)
struct SignInWithAppleButton: UIViewRepresentable {
    var action: () -> Void

    func makeUIView(context: Context) -> UIView {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(context.coordinator,
                         action: #selector(Coordinator.tapped),
                         for: .touchUpInside)
        button.addTarget(context.coordinator,
                         action: #selector(Coordinator.tapped),
                         for: .primaryActionTriggered)
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
#else
struct SignInWithAppleButton: View {
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 7, height: 7)
                Text("Sign in with Apple")
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
        }
        .background(.black)
        .cornerRadius(5)
        .tint(.white)
    }
}
#endif
