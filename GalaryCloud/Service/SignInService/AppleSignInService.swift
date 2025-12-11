//
//  AppleSignInService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import Foundation
import Combine
import AuthenticationServices

final class AppleSignInService: NSObject, ObservableObject, AuthorizationServiceProtocol, ASAuthorizationControllerDelegate {
    
    @Published var user: UserModel?
    
#if !os(watchOS)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        (UIApplication.shared.activeWindow?.rootViewController?.topViewController.view.window ?? UIApplication.shared.activeWindow) ?? .init()
    }
#endif
    
    func perform() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
#if !os(watchOS)
        controller.presentationContextProvider = self
        #endif
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credinails = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.user = .init(username: credinails.email, password: credinails.user)
        }
    }
}

#if !os(watchOS)
extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    
}
#endif
