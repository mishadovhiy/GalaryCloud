//
//  AuthorizationFieldsView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 26.11.2025.
//

import SwiftUI

struct AuthorizationFieldsView: View {
    
    typealias TextFieldsInput = [AuthorizationTextFieldType: String]
    
    var prompt: String? = nil
    @Binding var textFields: TextFieldsInput
    let nextButtonPressed: () -> ()
    @FocusState private var activeTextField: AuthorizationTextFieldType?
    
    var body: some View {
        let textFields = Array(textFields.keys.sorted(by: {
            $0.rawValue.count <= $1.rawValue.count
        }))
        ScrollView(.vertical, content: {
            VStack(alignment: .leading) {
                if let prompt {
                    Text(prompt)
                        .foregroundColor(.secondaryContainer)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                ForEach(textFields, id: \.rawValue) { key in
                    TextField(
                        "",
                        text: .init(get: {
                            self.textFields[key] ?? ""
                    }, set: { newValue in
                        self.textFields.updateValue(newValue, forKey: key)
                    }),
                        prompt: Text(key.rawValue)
                            .foregroundColor(.secondaryContainer.opacity(0.3)))
                    .foregroundColor(.secondaryContainer)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(.black.opacity(0.15))
                    .cornerRadius(8)
                    .focused($activeTextField, equals: key)
                    .onSubmit {
                        if self.textFields[key]?.isEmpty ?? true {
                            self.activeTextField = nil
                        } else if let nextIndex = textFields.firstIndex(of: key), nextIndex + 1 < textFields.count {
                            self.activeTextField = textFields[nextIndex + 1]
                        } else {
                            self.nextButtonPressed()
                        }
                        
                    }
                }
            }
            .frame(maxWidth: .infinity)
        })
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AuthorizationView.Constants.containerBackground)
        .onAppear {
            withAnimation {
                self.activeTextField = textFields.first
            }
        }
    }
}

extension AuthorizationFieldsView {
    enum AuthorizationTextFieldType: String, Hashable {
        case email
        case code
        case password
        case repeatedPassword
    }
}
