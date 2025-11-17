//
//  CachedAsyncImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct CachedAsyncImage: View {
    let username: String
    let fileName: String
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    @Binding var imagePresenting: UIImage?
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        imagePresenting = image
                    }
            }
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .task(priority: .userInitiated) {
            let response = await URLSession.shared.resumeTask(FetchImageRequest(urlPathSuffix: "/\(username)/\(fileName)"))
            await MainActor.run {
                isLoading = false
                switch response {
                case .success(let imageData):
                    self.image = .init(data: imageData)
                default: break
                }
            }
            
        }
    }
}
