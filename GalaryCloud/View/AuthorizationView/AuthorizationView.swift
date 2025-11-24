//
//  AuthorizationView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import SwiftUI

struct AuthorizationView: View {
    var body: some View {
        ZStack {
            AppFeaturesView()
            VStack {
                Spacer()
                
            }
        }
    }
    
    var authorizationNavigation: some View {
        NavigationView {
            VStack {
                
            }
        }
    }
    @State var textFields: [AuthorizationTextFieldType: String] = [:]
    enum AuthorizationType {
        case login, createAccount
    }
    enum AuthorizationTextFieldType: String {
        case email
        case code
        case password
        case repeatedPassword
    }
    
    var loginView: some View {
        VStack {
//            ForEach(textFields, id: \.key.rawValue) { dict in
//                TextField(dict.key.rawValue, text: .init(get: {
//                    dict.value
//                }, set: { newValue in
//                    textFields.updateValue(newValue, forKey: dict.key)
//                }))
//            }
        }
    }
    
    var createAccountView: some View {
        VStack {
            
        }
    }
}

