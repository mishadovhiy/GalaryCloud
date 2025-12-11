//
//  SignInService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import Combine
import Foundation

final class SignInService: NSObject, ObservableObject {

    @Published private var appleService: AppleSignInService?
    private var selectedType: AuthorizationType?
    
    var user: UserModel? {
        switch selectedType {
        case .apple:
            return appleService?.user
        default:
            return nil
        }
        
    }
    private var cancelable: AnyCancellable?
    
    func perform(_ type: AuthorizationType) {
        self.selectedType = type
        appleService?.user = nil
        switch type {
        case .apple:
            if appleService == nil {
                appleService = .init()
                cancelable = appleService?.objectWillChange.sink(receiveValue: { [weak self] _ in
                    self?.objectWillChange.send()
                })
            }
            self.appleService?.perform()
        }
    }
}

extension SignInService {
    enum AuthorizationType {
    case apple
    }
}

protocol AuthorizationServiceProtocol {
    var user: UserModel? { get set }
    func perform()
}
