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
    @Published var image: UIImage?
    @Published var date: String = ""
    @Published var isLoading: Bool = true
    @Published var messages: [MessageModel] = []
    @Published var urlTask: URLSessionDataTask?
    private let photoLibraryModifierService = PHPhotoLibraryModifierService()
    @Published var saveAnimating: Bool = false
    @Published var deleteAnimating: Bool = false
    private let filemamager = FileManagerService()

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
        if let imageData = filemamager.load(path: dataModel.username + dataModel.fileName, quality: .middle) {
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
                    self.filemamager.save(data: data, path: dataModel.username + dataModel.fileName)
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
    
    func performSaveImage(_ db: DataBaseService) {
        guard let data = self.image?.jpegData(compressionQuality: 1) else {
            print("error converting to data")
            return
        }
        saveAnimating = true
        let date = data.imageDate ?? date
        self.photoLibraryModifierService.save(
            data: data,
            date: date) { success in
                let title = success ? "Saved to Photos!" : "Error saving"
                db.messages.append(.init(title: title))
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.saveAnimating = false
                })
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
