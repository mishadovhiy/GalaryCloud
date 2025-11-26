//
//  AuthorizationViewModel.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 26.11.2025.
//

import SwiftUI
import Combine

class AuthorizationViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var error: NSError?
    @Published var dissmiss: Bool = false

    @Published var textFields: [NavigationLinkType: AuthorizationFieldsView.TextFieldsInput] = [:]
    @Published var authorizationType: AuthorizationType? {
        didSet { didSelectAuthorizationType() }
    }
    @Published var codeToEnter: String?
    
    private func didSelectAuthorizationType() {
        updateTextField(.credinails)
    }
    
    private func updateTextField(_ key: NavigationLinkType) {
        textFields.updateValue(
            textFieldFor(key: key),
            forKey: key)
    }
    
    private func textFieldFor(key: NavigationLinkType) -> AuthorizationFieldsView.TextFieldsInput {
        switch key {
        case .credinails:
            switch self.authorizationType {
            case .login:
                [
                    .email:"",
                    .password:"",
                    .repeatedPassword:""
                ]
            case .createAccount:
                [
                    .email:"",
                    .password:""
                ]
            case .passwordReset:
                [.email:""]
            default:
                [:]
            }
        case .createAccountCode:
            [.code:""]
        case .passwordResetEmail:
            [.email:""]
        case .passwordResetCode:
            [.code:""]
        case .passwordResetCreatePassword:
            [.password:"", .repeatedPassword:""]
        }
    }
    
    func navigationValue(_ key: NavigationLinkType) -> Binding<AuthorizationFieldsView.TextFieldsInput> {
        .init {
            self.textFields[key] ?? [:]
        } set: {
            print(key, " gdfsafdsgf " , $0)
            self.textFields.updateValue($0, forKey: key)
        }
    }
    
    
    var needNextButton: Bool {
        !textFields.isEmpty
    }
    
    func nextButtonPressed() {
        self.error = nil
        guard let authorizationType else {
            return
        }
        textFields.forEach { (key: NavigationLinkType, value: AuthorizationFieldsView.TextFieldsInput) in
            if value.contains(where: {$0.value.isEmpty}) {
                self.error = .init(domain: "all fields are reuqered", code: -1)
                return
            }
        }

        switch authorizationType {
        case .login:
            self.loginRequest()
            
        case .createAccount:
            createAccountNextPressed()
            
        case .passwordReset:
            passwordResetNextPressed()
        }
    }
    
    private func createAccountNextPressed() {
        guard let enteredCode = self.textFields[.createAccountCode]?.first(where: {$0.key == .code})?.value,
              let codeToEnter
        else {
            if let textFields = self.textFields[.credinails] {
                if textFields[.password] != textFields[.password] {
                    self.error = .init(domain: "passwords not match", code: -2)

                } else {
                    self.sendCodeRequest()

                }
            }
            return
        }
        if enteredCode != codeToEnter {
            self.error = .init(domain: "you have entered wrong code", code: -2)
        } else {
            self.createAccountRequest()
        }
    }
    
    private func passwordResetNextPressed() {
        guard let enteredCode = self.textFields[.passwordResetCode]?.first(where: {$0.key == .code})?.value,
              let codeToEnter
        else {
            self.sendPasswordResetCode()
            return
        }
        if enteredCode != codeToEnter {
            self.error = .init(domain: "you have entered wrong code", code: -2)
        } else {
            if let textFields = textFields[.passwordResetCreatePassword] {
                if textFields[.password] != textFields[.password] {
                    self.error = .init(domain: "passwords not match", code: -2)

                }
            } else {
                self.textFields.updateValue([
                    .password: "",
                    .repeatedPassword: ""
                ], forKey: .passwordResetCreatePassword)
            }
            
        }
    }
        
    private func sendCodeRequest() {
        self.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.isLoading = false
            self.codeToEnter = "1111"
            print("fdsdfsfds")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.textFields.updateValue([.code:""], forKey: .createAccountCode)
            })
        })
    }
    
    private func loginRequest() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.isLoading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.setSuccessLogin(username: "hi@mishadovhiy.com", password: "Mishka16")
            })
        })
    }
    
    private func setSuccessLogin(username: String,
                                 password: String) {
        KeychainService.saveToken(username, forKey: .userNameValue)
        KeychainService.saveToken(password, forKey: .userPasswordValue)
        self.dissmiss = true

    }
    
    private func createAccountRequest() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.isLoading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.setSuccessLogin(username: "hi@mishadovhiy.com", password: "Mishka16")
            })
        })
    }
    
    private func sendPasswordResetCode() {
        self.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.isLoading = false
            self.codeToEnter = "1111"
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.textFields.updateValue([.code:""], forKey: .passwordResetCode)
            })
        })
    }
    
    var navigationPath: Binding<[NavigationLinkType]> {
        .init(get: {
            Array(self.textFields.keys.sorted(by: {$0.order <= $1.order}))
        }, set: { newKeys in
            self.textFields.keys.forEach { key in
                if !newKeys.contains(key) {
                    self.textFields.removeValue(forKey: key)
                }
            }
            newKeys.forEach { key in
                if !self.textFields.keys.contains(key) {
                    self.updateTextField(key)
                }
            }
        })
    }
}

extension AuthorizationViewModel {
    enum AuthorizationType: String, CaseIterable {
        case login, createAccount, passwordReset
        
        var isMain: Bool {
            switch self {
            case .passwordReset: false
            default: true
            }
        }
    }
    
    enum NavigationLinkType: String, CaseIterable, Hashable {
        case credinails
        case createAccountCode
        case passwordResetEmail
        case passwordResetCode
        case passwordResetCreatePassword
        
        var order: Int {
            Self.allCases.firstIndex(of: self) ?? 0
        }
    }
}
