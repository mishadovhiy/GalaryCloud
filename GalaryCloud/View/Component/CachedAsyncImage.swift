//
//  CachedAsyncImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: String
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .task(priority: .userInitiated) {
            NetworkModel().loadFile(url: url) { image in
                self.image = .init(data: image ?? .init())
                self.isLoading = false
            }
            URLSession.shared.resumeTask(<#T##requestable: Requestable##Requestable#>)
        }
    }
}
