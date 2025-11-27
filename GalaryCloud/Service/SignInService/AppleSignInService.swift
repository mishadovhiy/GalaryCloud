//
//  AppleSignInService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import Foundation
import Combine
import AuthenticationServices

final class AppleSignInService: NSObject, ObservableObject, AuthorizationServiceProtocol, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @Published var user: UserModel?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        (UIApplication.shared.activeWindow?.rootViewController?.topViewController.view.window ?? UIApplication.shared.activeWindow) ?? .init()
    }
    
    func perform() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credinails = authorization.credential as? ASAuthorizationAppleIDCredential {
            print(
                credinails.user, " uniqiddd",
                credinails.email, " emaill"
            )
            self.user = .init(username: credinails.email, password: credinails.user)
        } else {
        }
    }
}
