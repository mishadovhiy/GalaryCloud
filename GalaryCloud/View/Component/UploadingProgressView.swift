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
            Text(error?.localizedDescription ?? "Uploading \(uploadingFilesCount)")
            if error != nil {
                Button("resend \(uploadingFilesCount) files") {
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
