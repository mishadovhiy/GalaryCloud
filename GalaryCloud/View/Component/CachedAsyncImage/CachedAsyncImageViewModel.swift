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
    @Published var isCurrentlyLoading: Bool = false
    @Published var image: UIImage?
    @Published var date: String = ""
    @Published var isLoading: Bool = true
    @Published var messages: [MessageModel] = []
#if !os(watchOS)
    private let photoLibraryModifierService = PHPhotoLibraryModifierService()
#endif
    @Published var saveAnimating: Bool = false
    @Published var deleteAnimating: Bool = false
    @Published var fetchError: Bool = false
    private let filemamager = FileManagerService()
    @Published var task: (Task<(), Never>)?

    func fetchCachedImage(
        db: DataBaseService,
        isSmallImageType: Bool,
        dataModel: PresentationType.GalaryModel
    ) -> Bool {
        if let image = db.imageCache.object(
            forKey: dataModel.fileName as NSString) {
            self.image = image
            isLoading = false
            return true
        }
        if let imageData = filemamager.load(
            path: dataModel.username + dataModel.fileName,
            quality: .middle) {
            var imageData = imageData
            #if os(tvOS) || os(watchOS)
            if isSmallImageType {
                imageData = UIImage(data: imageData)?
                    .changeSize(newWidth: 50)
                    .jpegData(compressionQuality: 0.01) ?? .init()
            }
            #endif
            self.image = .init(data: imageData)
            if isSmallImageType {
                self.isLoading = false
                return true
            }
        }
        return false
    }
    
    func viewDidDisapear() {
        if self.image == nil {
            task?.cancel()
        }
        image = nil
    }
    
    private func didFetchImage(
        data: Data?,
        db: DataBaseService,
        dataModel: PresentationType.GalaryModel, isSmall: Bool
    ) {
            self.isLoading = false

            if let data,
               let image = UIImage(data: data) {
                var image = image
                #if !os(tvOS) && !os(watchOS)
                db.imageCache.setObject(
                    image, forKey: dataModel.fileName as NSString,
                    cost: data.count)
                #else
if isSmall {
    image = image.changeSize(newWidth: 20)
}
                #endif
                self.image = image

                self.filemamager.save(
                    data: data,
                    path: dataModel.username + dataModel.fileName)
            } else {
                self.fetchError = true
            }
        }
    
    func fetchImage(
        db: DataBaseService,
        isSmallImageType: Bool
    ) {
        fetchError = false
        isLoading = true
        switch presentationType {
        case .galary(let dataModel):
            self.date = dataModel.date
            if fetchCachedImage(
                db: db,
                isSmallImageType: isSmallImageType,
                dataModel: dataModel) {
                return
            }
            task = Task(name: "imageLoading" + dataModel.fileName,
                        priority: .userInitiated) {
                let response = await URLSession.shared.resumeTask(
                    FetchImageRequest(
                        username: dataModel.username,
                        filename: dataModel.fileName)
                )
                let data = try? response.get()
                await MainActor.run {
                    self.didFetchImage(
                        data: data,
                        db: db,
                        dataModel: dataModel, isSmall: isSmallImageType)
                }
                
            }
        }
    }
    
    func performSaveImage(_ db: DataBaseService) {
        guard let data = self.image?.jpegData(
            compressionQuality: 1) else {
            print("error converting to data")
            return
        }
        saveAnimating = true
        let date = data.imageDate ?? date
#if !os(watchOS)
        self.photoLibraryModifierService.save(
            data: data,
            date: date) { success in
                let title = success ? "Saved to Photos!" : "Error saving"
                db.messages.append(.init(
                    header:success ? "Success" : "Error",
                    title: title)
                )
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + .seconds(1),
                    execute: {
                        self.saveAnimating = false
                    })
            }
#endif
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
