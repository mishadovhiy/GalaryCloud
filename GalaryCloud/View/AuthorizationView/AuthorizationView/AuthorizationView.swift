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
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
                AppFeaturesView()
                contentView
            }
            .animation(.bouncy, value: viewModel.authorizationType)
        }
        .onChange(of: viewModel.dissmiss) { newValue in
            db.checkIsUserLoggedIn = true
        }
        .onChange(of: viewModel.authorization.user ?? .init(username: "", password: "")) { newValue in
            viewModel.signInUserDidChange()
        }
    }
    
    var contentView: some View {
        VStack {
            NavigationStack(path: viewModel.navigationPath) {
                rootView
                    .navigationDestination(for: AuthorizationViewModel.NavigationLinkType.self) { key in
                        AuthorizationFieldsView(textFields: viewModel.navigationValue(key))
                    }
                    .background {
                        ClearBackgroundView()
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            nextButton
        }
        .padding(5)
        .background(.red)
        .cornerRadius(30)
        .frame(maxHeight: viewModel.authorizationType == nil ? 200 : .infinity)
        .padding(5)
    }
    
    var nextButton: some View {
        Button {
            viewModel.nextButtonPressed()
        } label: {
            Text("Next")
        }
        .modifier(LoadingButtonModifier(isLoading: viewModel.isLoading, isHidden: !viewModel.needNextButton))
        .clipped()
    }
    
    var rootView: some View {
        VStack(spacing: 10) {
            Spacer()
            ForEach(AuthorizationViewModel.AuthorizationType.allCases.filter(\.isMain), id: \.rawValue) { type in
                Button {
                    withAnimation(.bouncy) {
                        self.viewModel.authorizationType = type
                    }
                } label: {
                    Text(type.rawValue.capitalized)
                }
            }
            Spacer()
            HStack {
                HStack {
                    Button("Reset Password") {
                        self.viewModel.authorizationType = .passwordReset
                    }
                    .font(.footnote)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 2)
                    .background(.blue.opacity(0.15))
                    .cornerRadius(6)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                SignInWithAppleButton {
                    viewModel.authorization.perform(.apple)
                }
                .frame(maxWidth: 100)
                HStack{}.frame(maxWidth: .infinity)
            }
            .frame(height: 40)
        }
    }
}
