//
//  CachedAsyncImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI
import Photos
import Combine
import AWSCore
import AWSS3
struct CachedAsyncImage: View {
    
    let presentationType: PresentationType
    var didDeleteImage: (()->())? = nil

    @State private var image: UIImage?
    @State private var date: String = ""
    @State private var isLoading: Bool = true
    @State private var messages: [MessageModel] = []
    @EnvironmentObject var db: DataBaseService
    
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
                VStack {
                    ProgressView().progressViewStyle(.circular)
                    Text(date)
                }
            }
        }
        .modifier(AlertModifier(messages: $messages))
        .onAppear(perform: {
            fetchImage()
            
        })
        .onDisappear {
            image = nil
            self.task?.cancel()
        }
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
    
    func fetchURL(data: PresentationType.GalaryModel,
                  completion: @escaping(_ url: URL?)->()) {
        let request = AWSS3GetPreSignedURLRequest()
        request.bucket = "galary-cloud-dovhyi"
        request.key = "uploads/\(data.username)/\(data.fileName)"
        request.httpMethod = .GET
        request.expires = Date(timeIntervalSinceNow: 3600)
        
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(request).continueWith { task in
            if let url = task.result as? URL {
                completion(url)
            } else {
                completion(nil)
            }
            return nil
        }
    }
    @State var task: URLSessionDataTask?
    func fetchImage() {
        isLoading = true
        switch presentationType {
        case .galary(let dataModel):
            self.date = dataModel.date

            if let image = db.imageCache.object(forKey: dataModel.fileName as NSString) {
                self.image = image
                isLoading = false
                return
            }
            if let imageData = FileManager.default.load(path: dataModel.username + dataModel.fileName, quality: self.didDeleteImage == nil ? .middle : .middle) {
                self.image = .init(data: imageData)
                if self.didDeleteImage == nil {
                    self.isLoading = false
                    return
                }
            }
            Task {
                self.fetchURL(data: dataModel) { url in
                    task = URLSession.shared.dataTask(with: .init(url: url!)) { data, _, _ in
                        DispatchQueue.main.async {
                            if let data,
                                let image = UIImage(data: data) {
                                self.image = .init(data: data)
                                db.imageCache.setObject(image, forKey: dataModel.fileName as NSString, cost: data.count)
                                FileManager.default.save(data: data, path: dataModel.username + dataModel.fileName)
                            }
                            self.isLoading = false
                        }
                    }

                    task?.resume()
                    
                }
//                if let imageData = FileManager.default.load(path: dataModel.username + dataModel.fileName) {
//                    await MainActor.run {
//                        self.image = .init(data: imageData)
//                        self.date = imageData.imageDate ?? "?"
//                        self.isLoading = false
//                    }
//                    return
//                }
//                let response = await URLSession.shared.resumeTask(FetchImageRequest(username: dataModel.username, filename: dataModel.fileName))
                
//                await MainActor.run {
//                    isLoading = false
//                    switch response {
//                    case .success(let imageData):
//                        self.image = .init(data: imageData)
//                        self.date = imageData.imageDate ?? "?"
////                        FileManager.default.save(data: imageData, path: dataModel.username + dataModel.fileName)
//                    default: break
//                    }
//                }
            }
        }
        
    }
    
    func deleteApiImage(_ data: PresentationType.GalaryModel) {
        isLoading = true
        Task {
            let request = await URLSession.shared.resumeTask(DeleteFileRequest(username: data.username, filename: data.fileName))
            FileManager.default.delete(path: data.username + data.fileName)
            await MainActor.run {
                isLoading = false
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
        
        struct GalaryModel: Equatable {
            let username: String
            let fileName: String
            let date: String
        }
        
        var galaryModel: GalaryModel? {
            switch self {
            case .galary(let galaryModel):
                galaryModel
            }
        }
        
        var hasValue: Bool {
            switch self {
            case .galary(let galaryModel):
                !galaryModel.fileName.isEmpty
            }
        }
    }
}


