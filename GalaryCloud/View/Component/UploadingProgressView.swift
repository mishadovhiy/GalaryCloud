//
//  UploadingProgressView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct UploadingProgressView: View {
    
    let uploadingFilesCount: Int
    let error: Error?
    let resendPressed: ()->()
    
    var body: some View {
        HStack {
            Text(error?.localizedDescription ?? "Uploading")
            if error != nil {
                Button("resend") {
                    resendPressed()
                }
            }
        }
        .background(.black.opacity(0.1))
        .cornerRadius(9)
        .shadow(radius: 10)
        .padding(12)
        .opacity(0.5)
    }
}
