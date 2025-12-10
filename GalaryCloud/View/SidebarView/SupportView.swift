//
//  SupportView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import SwiftUI

struct SupportView: View {
    
    @State private var supportRequest = SupportRequest(title:"", head: "", body: "")
    @State private var error: NSError?
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var db: DataBaseService
    
    var body: some View {
        VStack {
            if let error {
                Text(error.unparcedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            TextField(
                "",
                text: $supportRequest.head,
                prompt: Text("Header")
                    .foregroundColor(.secondaryText)
            )
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(.secondaryContainer)
            .cornerRadius(8)
            textView
            HStack {
                Spacer()
                Button("Send") {
                    self.sendRequest()
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 15)
                .modifier(LoadingButtonModifier(isLoading: isLoading, type: .small))
            }
        }
        .padding(.horizontal, 10)
        .background(content: {
            ClearBackgroundView()
        })
        .background(SidebarView.Constants.background)
        .onAppear {
            supportRequest.title = KeychainService.username
        }
    }
    
    var textView: some View {
        #if os(tvOS)
        EmptyView()
            .frame(height: 10)
        #else
        TextEditor(text: $supportRequest.body)
        .background(.secondaryContainer)
            .scrollContentBackground(.hidden)
            .cornerRadius(8)
            .overlay {
                VStack {
                    
                    HStack {
                        Text("Your message")
                            .foregroundColor(.secondaryText)
                            .opacity(!supportRequest.body.isEmpty ? 0 : 1)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 5)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .foregroundColor(.primaryText)
        #endif
    }
    
    func sendRequest() {
        if self.supportRequest.body.isEmpty {
            db.messages.append(.init(title: "Enter your message"))

            return
        }
        isLoading = true
        self.error = nil
        Task {
            let request = await URLSession.shared.resumeTask(self.supportRequest)
            await MainActor.run {
                isLoading = false
                do {
                    let _ = try request.get().success
                    self.dismiss()
                    db.messages.append(.init(title: "Support request has been send Successfully"))
                } catch {
                    self.error = error as NSError
                }
            }
            
        }
    }
}

#Preview {
    SupportView()
}
