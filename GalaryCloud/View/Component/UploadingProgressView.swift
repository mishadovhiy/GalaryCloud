//
//  UploadingProgressView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct UploadingProgressView: View {
    let showResend: Bool
    let currentItem: URL
    let uploadingFilesCount: Int
    let error: Error?
    let resendPressed: ()->()
    
    var body: some View {
        HStack(spacing: 6) {
#if !os(watchOS)
            Image(uiImage: uploadImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(4)
                .clipped()
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.outline, lineWidth: 0.6)
                }
#endif
            VStack(alignment: .leading) {
                Text(error?.unparcedDescription ?? "Uploading \(uploadingFilesCount)")
                    .foregroundColor(error != nil ? .red : .secondaryContainer)
                    .lineLimit(error == nil ? 1 : 0)
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .leading)
                    .font(.footnote)
                if error == nil {
                    Text(currentItem.lastPathComponent)
                        .foregroundColor(.secondaryContainer.opacity(0.4))
                        .font(.footnote)
                        .lineLimit(error == nil ? 1 : 0)
                        .frame(maxWidth: 120, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if error != nil || showResend {
                Button("Resend\n\(uploadingFilesCount) files") {
                    resendPressed()
                }
                .modifier(LinkButtonModifier())
                .multilineTextAlignment(.leading)
            }
        }
        .padding(6)
        .modifier(CircularButtonModifier(color: .light, cornerRadius: 12))
        .frame(maxHeight: Constants.height)
        .shadow(radius: 10)
        .padding(12)
    }
#if !os(watchOS)
    var uploadImage: UIImage {
        do {
            return UIImage(data: try Data(contentsOf: currentItem)) ?? .defaultUpload
        } catch {
            return .defaultUpload
        }
    }
    #endif
}

extension UploadingProgressView {
    struct Constants {
        static let height: CGFloat = 60
    }
}
