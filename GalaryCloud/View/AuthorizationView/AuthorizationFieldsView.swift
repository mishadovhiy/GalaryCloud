//
//  AuthorizationFieldsView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 26.11.2025.
//

import SwiftUI

struct AuthorizationFieldsView: View {
    
    typealias TextFieldsInput = [AuthorizationTextFieldType: String]
    @Binding var textFields: TextFieldsInput
    
    var body: some View {
        ScrollView(.vertical, content: {
            VStack {
                ForEach(Array(textFields.keys.sorted(by: {
                    $0.rawValue.count <= $1.rawValue.count
                })), id: \.rawValue) { key in
                    TextField(
                        "",
                        text: .init(get: {
                        textFields[key] ?? ""
                    }, set: { newValue in
                        textFields.updateValue(newValue, forKey: key)
                    }),
                        prompt: Text(key.rawValue)
                            .foregroundColor(.primaryText.opacity(0.3)))
                    .foregroundColor(.primaryText)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(.primaryContainer)
                    .cornerRadius(7)
                }
            }
        })
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AuthorizationView.Constants.containerBackground)
    }
}

extension AuthorizationFieldsView {
    enum AuthorizationTextFieldType: String {
        case email
        case code
        case password
        case repeatedPassword
    }
}
