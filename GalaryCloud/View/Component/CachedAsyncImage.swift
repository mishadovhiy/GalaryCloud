//
//  CachedAsyncImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct CachedAsyncImage: View {
    let presentationType: PresentationType
    @State private var image: UIImage?
    @State private var date: String = ""
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            if let image {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    Text(date)
                }
            }
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .onAppear(perform: {
            fetchImage()
            
        })
    }
    
    func fetchImage() {
        switch presentationType {
        case .galary(let dataModel):
            Task {
                let response = await URLSession.shared.resumeTask(FetchImageRequest(username: dataModel.username, filename: dataModel.fileName))
                await MainActor.run {
                    isLoading = false
                    switch response {
                    case .success(let imageData):
                        self.image = .init(data: imageData)
                        self.date = imageData.imageDate ?? "?"
                    default: break
                    }
                }
            }
        }
        
    }
    
    
}

extension CachedAsyncImage {
    enum PresentationType {
        case galary(GalaryModel)
        struct GalaryModel {
            let username: String
            let fileName: String
        }
        
        var hasValue: Bool {
            switch self {
            case .galary(let galaryModel):
                !galaryModel.fileName.isEmpty
            }
        }
    }
}
