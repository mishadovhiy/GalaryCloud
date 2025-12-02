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
                Text(error.localizedDescription)
            }
            TextField(
                "",
                text: .init(get: {
                    supportRequest.head
                }, set: {
                    supportRequest.head = $0
                }),
                prompt: Text("Header")
                    .foregroundColor(.secondaryText)
            )
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            TextEditor(text: .init(get: {
                supportRequest.body
            }, set: {
                supportRequest.body = $0
            }))
                .scrollContentBackground(.hidden)
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
            HStack {
                Spacer()
                Button("send") {
                    self.sendRequest()
                }
                .padding(.horizontal, 15)
                .modifier(LoadingButtonModifier(isLoading: isLoading))
            }
        }
        .padding(.horizontal, 10)
        .background(content: {
            ClearBackgroundView()
        })
        .background(SidebarView.Constants.background)
        .onAppear {
            supportRequest.title = "hi@mishadovhiy.com"
        }
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
                    if try request.get().success {
                        self.dismiss()
                        db.messages.append(.init(title: "Support request has been send Successfully"))
                    } else {
                        self.error = .init(domain: "Error sending request", code: -5)
                    }
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
