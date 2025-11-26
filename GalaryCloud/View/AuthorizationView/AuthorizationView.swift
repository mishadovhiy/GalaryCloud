//
//  AuthorizationView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import SwiftUI
import Combine

struct AuthorizationView: View {
    
    @StateObject var viewModel: AuthorizationViewModel = .init()
    @EnvironmentObject private var db: DataBaseService

    var body: some View {
        ZStack {
            VStack {
                AppFeaturesView()
                VStack {
                    authorizationNavigation
                    nextButton
                }
                .padding(15)
                .background(.red)
                .cornerRadius(30)
                .frame(maxHeight: viewModel.authorizationType == nil ? 200 : .infinity)
            }
            .animation(.bouncy, value: viewModel.authorizationType)
        }
        .onChange(of: viewModel.dissmiss) { newValue in
            db.checkIsUserLoggedIn = true
        }
    }
    
    var nextButton: some View {
        Button {
            viewModel.nextButtonPressed()
        } label: {
            Text("Next")
        }
        .frame(maxWidth: .infinity, maxHeight: viewModel.needNextButton ? 44 : 0)
        .background(.blue)
        .tint(.white)
        .font(.title)
        .cornerRadius(9)
        .animation(.smooth, value: viewModel.needNextButton)
        .clipped()
    }
    
    var authorizationNavigation: some View {
        NavigationView {
            VStack(spacing: 10) {
                ForEach(AuthorizationType.allCases, id: \.rawValue) { type in
                    Button {
                        withAnimation(.bouncy) {
                            self.viewModel.authorizationType = type
                        }
                    } label: {
                        Text(type.rawValue.capitalized)
                    }
                }
            }
            .overlay {
                NavigationLink("", destination: AuthorizationFieldsView(textFields: $viewModel.textFields), isActive: $viewModel.authorizationViewPresenting)
                .hidden()
            }
        }
    }
}


class AuthorizationViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var error: NSError?
    @Published var dissmiss: Bool = false

    @Published var textFields: AuthorizationFieldsView.TextFieldsInput = [:]
    @Published var authorizationType: AuthorizationView.AuthorizationType? {
        didSet { didSelectAuthorizationType() }
    }
    @Published private var codeToEnter: String?
    
    private func didSelectAuthorizationType() {
        switch authorizationType {
        case .createAccount:
            textFields = [
                .email:"",
                .password:"",
                .repeatedPassword:""
            ]
        case .login:
            textFields = [
                .email:"",
                .password:""
            ]
        default: break
            
        }
    }
    
    var authorizationViewPresenting: Bool {
        get {
            !textFields.isEmpty
        }
        set {
            if !newValue {
                textFields.removeAll()
                codeToEnter = nil
                authorizationType = nil
            }
        }
    }
    
    var needNextButton: Bool {
        authorizationType != nil
    }
    
    func nextButtonPressed() {
        guard let authorizationType else {
            fatalError()
            return
        }
        if textFields.contains(where: {$0.value.isEmpty}) {
            self.error = .init(domain: "all fields are reuqered", code: -1)
            return
        }
        switch authorizationType {
        case .login:
            self.loginRequest()
            
        case .createAccount:
            createAccountNextPressed()
        }
    }
    
    private func createAccountNextPressed() {
        guard let enteredCode = self.textFields.first(where: {$0.key == .code})?.value,
              let codeToEnter
        else {
            self.sendCodeRequest()
            return
        }
        if enteredCode != codeToEnter {
            self.error = .init(domain: "you have entered wrong code", code: -2)
        } else {
            self.createAccountRequest()
        }
    }
        
    private func sendCodeRequest() {
        self.isLoading = true
        
    }
    
    private func loginRequest() {
        
    }
    
    private func createAccountRequest() {
        
    }
}

extension AuthorizationView {
    enum AuthorizationType: String, CaseIterable {
        case login, createAccount
    }
}
