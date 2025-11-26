//
//  CachedAsyncImageViewModel.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 26.11.2025.
//

import Combine
import UIKit

class CachedAsyncImageViewModel: ObservableObject {
    
    let presentationType: PresentationType
    init(presentationType: PresentationType) {
        self.presentationType = presentationType
    }
    private let photoLibraryModifierService = PHPhotoLibraryModifierService()
    @Published var image: UIImage?
    @Published var date: String = ""
    @Published var isLoading: Bool = true
    @Published var messages: [MessageModel] = []
    @Published var urlTask: URLSessionDataTask?
    
    private func fetchCachedImage(
        db: DataBaseService,
        isSmallImageType: Bool,
        dataModel: PresentationType.GalaryModel
    ) -> Bool {
        if let image = db.imageCache.object(forKey: dataModel.fileName as NSString) {
            self.image = image
            isLoading = false
            return true
        }
        if let imageData = FileManager.default.load(path: dataModel.username + dataModel.fileName, quality: .middle) {
            self.image = .init(data: imageData)
            if isSmallImageType {
                self.isLoading = false
                return true
            }
        }
        return false
    }
    
    func viewDidDisapear() {
        image = nil
        urlTask?.cancel()
    }
    
    private func loadImage(
        db: DataBaseService,
        url: URL,
        dataModel: PresentationType.GalaryModel
    ) {
        self.urlTask = URLSession.shared.dataTask(with: .init(url: url)) { data, _, _ in
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

        self.urlTask?.resume()
    }
    
    func fetchImage(
        db: DataBaseService,
        isSmallImageType: Bool
    ) {
        isLoading = true
        switch presentationType {
        case .galary(let dataModel):
            self.date = dataModel.date
            if fetchCachedImage(db: db, isSmallImageType: isSmallImageType, dataModel: dataModel) {
                return
            }
            Task {
                WasabiService.fetchURL(
                    username: dataModel.username,
                    filename: dataModel.fileName
                ) { url in
                    guard let url else {
                        self.isLoading = false
                        return
                    }
                    self.loadImage(
                        db: db,
                        url: url,
                        dataModel: dataModel)
                }
            }
        }
        
    }
    
    private func deleteApiImage(
        _ data: PresentationType.GalaryModel,
        didDelete: @escaping()->()) {
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
                                didDelete()
                                self.isLoading = false
                                
                            })
                        ]))
                    }
                default: break
                }
            }
        }
    }
    
    func deletePressed(didDelete: @escaping()->()) {
        switch self.presentationType {
        case .galary(let galaryModel):
            messages.append(.init(title: "are you sure you wanna delete this?", buttons: [
                .init(title: "no"),
                .init(title: "yes", didPress: {
                    self.deleteApiImage(galaryModel, didDelete: didDelete)
                })
            ]))
        }
    }
    
    func savePressed() {
        guard let data = image?.jpegData(compressionQuality: 1) else {
            return
        }
        self.photoLibraryModifierService.save(
            data: data,
            date: date) { success in
                let title = success ? "Saved to Photos!" : "Error saving"
                self.messages.append(.init(title: title))
            }
    }
    
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
