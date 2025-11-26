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
        ForEach(Array(textFields.keys), id: \.rawValue) { key in
            TextField(key.rawValue, text: .init(get: {
                textFields[key] ?? ""
            }, set: { newValue in
                textFields.updateValue(newValue, forKey: key)
            }))
        }
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
