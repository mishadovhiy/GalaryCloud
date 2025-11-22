//
//  CachedAsyncImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI
import Photos
import Combine

struct CachedAsyncImage: View {
    
    let presentationType: PresentationType
    var didDeleteImage: (()->())? = nil

    @State private var image: UIImage?
    @State private var date: String = ""
    @State private var isLoading: Bool = true
    @State private var messages: [MessageModel] = []
    
    var body: some View {
        ZStack {
            if let image {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    Spacer()
                    HStack {
                        Text(date)
                        if didDeleteImage != nil {
                            Spacer()
                            buttons
                        }

                    }
                }
            }
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .modifier(AlertModifier(messages: $messages))
        .onAppear(perform: {
            fetchImage()
            
        })

    }
    
    @ViewBuilder
    var buttons: some View {
        Button {
            savePressed()
        } label: {
            Text("save")
        }
        Button {
            deletePressed()
        } label: {
            Text("delete")
        }
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
    
    func deleteApiImage(_ data: PresentationType.GalaryModel) {
        isLoading = true
        Task {
            let request = await URLSession.shared.resumeTask(DeleteFileRequest(username: data.username, filename: data.fileName))
            switch request {
            case .success(let data):
                if data.success {
                    messages.append(.init(title: "Image Deleted", buttons: [
                        .init(title: "OK", didPress: {
                            didDeleteImage?()
                            isLoading = false
                            
                        })
                    ]))
                }
            default: break
            }
        }
    }
    
    func deletePressed() {
        switch self.presentationType {
        case .galary(let galaryModel):
            messages.append(.init(title: "are you sure you wanna delete this?", buttons: [
                .init(title: "no"),
                .init(title: "yes", didPress: {
                    deleteApiImage(galaryModel)
                })
            ]))
        }
    }
    
    func savePressed() {
        PHPhotoLibrary.shared().performChanges({

                let request = PHAssetCreationRequest.forAsset()
            request.creationDate = .init(string: date)
            request.addResource(with: .photo, data: image!.jpegData(compressionQuality: 1)!, options: nil)
            }) { success, error in
                let title = success ? "Saved to Photos!" : "Error saving"
                DispatchQueue.main.async {
                    messages.append(.init(title: title))
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
