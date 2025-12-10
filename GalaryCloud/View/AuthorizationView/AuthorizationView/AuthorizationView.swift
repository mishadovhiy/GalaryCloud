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
                    Text(error.unparcedDescription)
                        .modifier(ErrorViewModifier())
                        .animation(.bouncy, value: viewModel.error != nil)
                        .transition(.move(edge: .top))
                }
                #if !os(watchOS)
                NavigationView {
                    AppFeaturesView(isKeyboardFocused: isKeyboardFocused)
                        .navigationViewStyle(.stack)
                        .background {
                            ClearBackgroundView()
                        }
                }
                .navigationViewStyle(.stack)
                .background {
                    ClearBackgroundView()
                }
                #endif
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
            withAnimation(.smooth(duration: 0.8)) {
                viewModel.appeared = true
            }
        }
    }

    var contentView: some View {
        VStack {
            NavigationStack(path: viewModel.navigationPath) {
                VStack(content: {
                    if needScrollView {
                        ScrollView(.vertical) {
                            rootView
                        }
                    } else {
                        rootView
                    }
                })
                    .navigationDestination(for: AuthorizationViewModel.NavigationLinkType.self) { key in
                        AuthorizationFieldsView(
                            prompt: viewModel.textFieldsViewPrompt(key),
                            textFields: viewModel.navigationValue(key), nextButtonPressed: {
                            self.viewModel.nextButtonPressed()
                        })
                        .navigationTitle((key.title ?? viewModel.authorizationType?.title) ?? "")
                        .focused($isKeyboardFocused)
                        .onAppear {
                            withAnimation {
                                viewModel.isLoading = false
                            }
                        }
                    }
                    .background {
                        ClearBackgroundView()
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            nextButton
        }
        .padding(containerStyle.contentPadding)
        .background(Constants.containerBackground)
        .cornerRadius(30)
        .overlay(content: {
            if containerStyle.needOutlines {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.black, lineWidth: 1)
            }
        })
        .shadow(radius: containerStyle.shadow)
        .frame(maxHeight: containerStyle.needOutlines ? contentHeight : .infinity)
        .padding(.bottom, containerStyle.bottomPadding)
        .padding(.horizontal, containerStyle.horizontalPadding)
    }
    
    var nextButton: some View {
        Button {
            self.isKeyboardFocused = false
            viewModel.nextButtonPressed()
        } label: {
            Text("Next")
        }
        .frame(maxWidth: viewModel.isLoading ? nil : .infinity)
        .modifier(LoadingButtonModifier(isLoading: viewModel.isLoading, isHidden: !viewModel.needNextButton))
        .animation(.bouncy, value: viewModel.isLoading)
        .clipped()
        .shadow(color: .accentColor, radius: 10)
    }
    
    var rootView: some View {
        VStack(spacing: viewModel.appeared ? 10 : 200) {
            ForEach(AuthorizationViewModel.AuthorizationType.allCases.filter(\.mainList), id: \.rawValue) { type in
                Button {
                    withAnimation(.bouncy) {
                        self.viewModel.authorizationType = type
                    }
                } label: {
                    Text(type.rawValue.addSpaceBeforeCapitalizedLetters.capitalized)
                        .font(.headline)
                        .shadow(radius: 3)
                }
                .tint(type.primaryStyle ? .primaryText : .black)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(.black.opacity(type.primaryStyle ? 1 : 0.15))
                .cornerRadius(12)
            }
            Spacer()
            HStack(alignment: .bottom) {
                HStack(alignment: .bottom) {
                    Button("Reset Password") {
                        self.viewModel.authorizationType = .passwordReset
                    }
                    .font(.footnote)
                    .tint(.secondaryText)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                #if !os(watchOS)
                SignInWithAppleButton {
                    viewModel.authorization.perform(.apple)
                }
                .frame(maxWidth: 100)
                .opacity(viewModel.appeared ? 1 : 0)
                .animation(.smooth(duration: 1.2), value: viewModel.appeared)
                #endif
                HStack{}.frame(maxWidth: .infinity)
            }
            .frame(height: 40)
        }
        .onAppear {
            withAnimation {
                self.viewModel.textFields.removeAll()
                self.viewModel.isLoading = false
                self.viewModel.error = nil
            }
        }
    }
}

extension AuthorizationView {
    var containerStyle: ContainerStyle {
        #if !os(watchOS)
        return .init(
            shadow: 10,
            contentPadding: 10,
            needOutlines: true,
            needMaxHeight: true,
            bottomPadding: 5,
            horizontalPadding: 15)
        #else
        return .init(
            shadow: 5,
            contentPadding: 0,
            needOutlines: false,
            needMaxHeight: false,
            bottomPadding: 0,
            horizontalPadding: 0)
        #endif
    }
    struct ContainerStyle {
        let shadow: CGFloat
        let contentPadding: CGFloat
        let needOutlines: Bool
        let needMaxHeight: Bool
        let bottomPadding: CGFloat
        let horizontalPadding: CGFloat
    }
    
    var contentHeight: CGFloat {
        if viewModel.authorizationType == nil {
            #if os(tvOS)
            return 350
            #else
            return 200
            #endif
        } else {
            return .infinity
        }
    }
    
    var needScrollView: Bool {
#if os(watchOS)
        return true
#elseif os(tvOS)
        return true
#else
return false
#endif
    }
}

extension AuthorizationView {
    struct Constants {
        static let containerBackground: Color = .white
    }
}
