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
    @FocusState var isKeyboardFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
                AppFeaturesView(isKeyboardFocused: isKeyboardFocused)
                contentView
                    .frame(maxHeight: viewModel.appeared ? nil : 0)
                    .clipped()
                    .animation(.bouncy, value: viewModel.appeared)
            }
            .padding(.top, 10)
            .animation(.bouncy, value: viewModel.authorizationType)
        }
        .onChange(of: viewModel.dissmiss) { newValue in
            db.checkIsUserLoggedIn = true
        }
        .onChange(of: viewModel.authorization.user ?? .init(username: "", password: "")) { newValue in
            viewModel.signInUserDidChange()
        }
        .onAppear {
            print("fsdfaz")
            withAnimation(.smooth(duration: 0.8)) {
                viewModel.appeared = true
            }
        }
    }
    
    var contentView: some View {
        VStack {
            NavigationStack(path: viewModel.navigationPath) {
                rootView
                    .navigationDestination(for: AuthorizationViewModel.NavigationLinkType.self) { key in
                        AuthorizationFieldsView(textFields: viewModel.navigationValue(key))
                            .navigationTitle(key.rawValue)
                            .focused($isKeyboardFocused)
                    }
                    .background {
                        ClearBackgroundView()
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            nextButton
        }
        .padding(10)
        .background(Constants.containerBackground)
        .cornerRadius(30)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 30)
                .stroke(.black, lineWidth: 1)
        })
        .shadow(radius: 10)
        .frame(maxHeight: viewModel.authorizationType == nil ? 200 : .infinity)
        .padding(.bottom, 5)
        .padding(.horizontal, 15)
    }
    
    var nextButton: some View {
        Button {
            self.isKeyboardFocused = false
            viewModel.nextButtonPressed()
        } label: {
            Text("Next")
        }
        .modifier(LoadingButtonModifier(isLoading: viewModel.isLoading, isHidden: !viewModel.needNextButton))
        .clipped()
    }
    
    var rootView: some View {
        VStack(spacing: viewModel.appeared ? 10 : 200) {
            ForEach(AuthorizationViewModel.AuthorizationType.allCases.filter(\.mainList), id: \.rawValue) { type in
                Button {
                    withAnimation(.bouncy) {
                        self.viewModel.authorizationType = type
                    }
                } label: {
                    Text(type.rawValue.capitalized)
                }
                .tint(type.primaryStyle ? .primaryText : .black)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(.black.opacity(type.primaryStyle ? 1 : 0.15))
                .cornerRadius(12)
            }
            Spacer()
            HStack {
                HStack {
                    Button("Reset Password") {
                        self.viewModel.authorizationType = .passwordReset
                    }
                    .font(.footnote)
                    .tint(.secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                SignInWithAppleButton {
                    viewModel.authorization.perform(.apple)
                }
                .frame(maxWidth: 100)
                .opacity(viewModel.appeared ? 1 : 0)
                .animation(.smooth(duration: 1.2), value: viewModel.appeared)
                HStack{}.frame(maxWidth: .infinity)
            }
            .frame(height: 40)
        }
    }
}

extension AuthorizationView {
    struct Constants {
        static let containerBackground: Color = .white
    }
}
