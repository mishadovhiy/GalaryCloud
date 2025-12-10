//
//  SignInService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import Combine
import Foundation

final class SignInService: NSObject, ObservableObject {
#if !os(watchOS)
    @Published private var appleService: AppleSignInService?
#endif
    private var selectedType: AuthorizationType?
    
    var user: UserModel? {
        switch selectedType {
        case .apple:
#if !os(watchOS)
            return appleService?.user
            #else
            return nil
#endif
        default:
            return nil
        }
        
    }
    private var cancelable: AnyCancellable?
    
    func perform(_ type: AuthorizationType) {
        self.selectedType = type
#if !os(watchOS)
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
#endif
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
