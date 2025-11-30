//
//  FileListViewModel.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Combine
import SwiftUI
struct ImageSelection {
    let file: FetchFilesResponse.File
    let index: Int
}
class FileListViewModel: ObservableObject {
    typealias File = FetchFilesResponse.File
    @Published var files: [File] = []
    @Published var fetchError: NSError?
    @Published var uploadError: NSError?
    @Published var directorySizeResponse: DirectorySizeResponse?
    @Published var fetchRequestLoading: Bool = false
    @Published var uploadIndicatorSize: CGSize = .zero
    @Published var photoLibrarySelectedURLs: [URL] = []
    @Published var isPhotoLibraryPresenting: Bool = false
    @Published var selectedImagePreviewPresenting: ImageSelection?
    @Published var messages: [MessageModel] = []
    #warning("remove photo library presenting bool, its not used imagePreviewPresenting used indeed")
    @Published var selectedFileIDs: Set<String> = []
    @Published var lastDroppedID: String?
    @Published var isEditingList: Bool = false {
        didSet {
            if !isEditingList {
                withAnimation {
                    self.selectedFileIDs.removeAll()
                }
            }
            
        }
    }
    var imagePreviewPresenting: Bool {
        get {
            selectedImagePreviewPresenting != nil
        }
        set {
            if !newValue {
                self.selectedImagePreviewPresenting = nil
            }
        }
    }
    @Published var selectedFilesActionType: SelectedFilesActionType?
    private var requestOffset: Int = 0
    private let photoLibraryModifierService = PHPhotoLibraryModifierService()
    var totalFileRecords: Int?
    
    func fetchDirectoruSizeRequest(completion:(()->())? = nil) {
        Task {
            let response = await URLSession.shared.resumeTask(DirectorySizeRequest(path: "hi@mishadovhiy.com"))
            await MainActor.run {
                switch response {
                case .success(let response):
                    self.directorySizeResponse = response
                    
                    completion?()
                default: break
                }
            }
        }
    }
    
    func fetchList(ignoreOffset: Bool = false, reload: Bool = false) {
        if fetchRequestLoading {
            print("request is already loading")
            return
        }
        if let totalFileRecords,
           !reload, !ignoreOffset, totalFileRecords <= files.count {
            print("no more records")
            return
        }
        if reload {
            self.requestOffset = 0
            self.files.removeAll()
        }
        fetchRequestLoading = true
        fetchError = nil
        Task(priority: .userInitiated) {
            let response = await URLSession.shared.resumeTask(FetchFilesRequest(offset: requestOffset, username: "hi@mishadovhiy.com"))
            
            await MainActor.run {
                self.fetchRequestLoading = false
                switch response {
                    
                case .success(let result):
                    var canUpdateData = ignoreOffset || reload
                    if let totalFileRecords,
                       ignoreOffset
                    {
                        if totalFileRecords != result.totalRecords {
                            canUpdateData = true
                        }
                    } else {
                        canUpdateData = true
                    }
                    if canUpdateData {
                        self.totalFileRecords = result.totalRecords
                        self.files.append(contentsOf: result.results)
                        self.requestOffset += 1
                    }
                    print(canUpdateData, " htrgerfds ")
                    if self.directorySizeResponse == nil {
                        self.fetchDirectoruSizeRequest()
                    }
                case .failure(let error):
                    self.fetchError = error as NSError
                }
            }
        }
    }

    func didCompletedUploadingFiles() {
        self.requestOffset = 0
        self.files.removeAll()
        self.directorySizeResponse = nil
        FileManager.default.clearTempFolder()
        self.fetchList(ignoreOffset: true)
        self.uploadAnimating = false
    }
    
    func uploadFilePressed(_ db: DataBaseService) {
        Task {
            await db.storeKitService.fetchActiveProducts()
            let gbUser = (self.directorySizeResponse?.bytes.megabytes ?? 0) / 1000
            print(gbUser, "gb used")
            if Double(db.storeKitService.activeSubscriptionGB) >= gbUser {
                await MainActor.run {
                    self.isPhotoLibraryPresenting = true
                }
            } else {
                await MainActor.run {
                    self.messages.append(.init(title: "Storage limit increesed, upgrade to pro to proceed", buttons: [
                        .init(title: "cancel"),
                        .init(title: "upgrade", didPress: {
                            db.forcePresentUpgradeToPro = true
                        })
                    ]))
                }
            }
        }
    }
    
    func upload() {
        //check gb limit, if cannot, show alert and present Uploading progress view
        //item uploaded, add file manually
        // on upload start - check storekit limit
        self.uploadError = nil
        guard let url = self.photoLibrarySelectedURLs.first else {
            self.uploadAnimating = false
            return
        }
        
        guard let imageData = try? Data(contentsOf: url) else {
            if !self.photoLibrarySelectedURLs.isEmpty {
                self.photoLibrarySelectedURLs.removeFirst()
                self.uploadAnimating = false
            }
            return
        }
        self.uploadAnimating = true
        let date = imageData.imageDate
        let apiData = CreateFileRequest.Image(url: url.lastPathComponent, date: date ?? Date().string, data: imageData.base64EncodedString())
        Task(priority: .userInitiated) {
            let response = await URLSession.shared.resumeTask(CreateFileRequest(username: "hi@mishadovhiy.com", originalURL: [apiData]))
            
            await MainActor.run {
                switch response {
                    
                case .success(let result):
                    if result.success {
                        self.photoLibrarySelectedURLs.removeFirst()
                        if photoLibrarySelectedURLs.isEmpty {
                            self.didCompletedUploadingFiles()
                        } else {
                            self.files.insert(.init(originalURL: url.lastPathComponent, date: date ?? Date().string), at: 0)
                            self.upload()
                        }
                    }
                    
                case .failure(let error):
                    self.uploadError = error as NSError
                    self.uploadAnimating = false
                }
            }
        }
    }
    
    private func deleteApiImage(
        _ filename: String, completed: ((_ ok: Bool)->())? = nil) {
//        isLoading = true
        Task {
            let request = await URLSession.shared.resumeTask(DeleteFileRequest(username: "hi@mishadovhiy.com", filename: filename))
            FileManager.default.delete(path: "hi@mishadovhiy.com" + filename)
            await MainActor.run {
//                isLoading = false
                let errorMessage: String?
                switch request {
                    
                case .success(let data):
                    errorMessage = data.success ? nil : "error deleting image"
                    
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    
                }
                if let completed {
                    self.files.removeAll(where: {
                        $0.originalURL == filename
                    })
                    completed(errorMessage == nil)
                } else {
                    messages.append(.init(title: errorMessage ?? "Image Deleted", buttons: [
                        .init(title: "OK", didPress: {
                            if errorMessage == nil {
                                self.files.removeAll(where: {
                                    $0.originalURL == filename
                                })
                            }
                            
                            self.imagePreviewPresenting = false

                        })
                    ]))
                }
            }
        }
    }
    
    func deletePressed(filename: String) {
        messages.append(.init(title: "are you sure you wanna delete this?", buttons: [
            .init(title: "no"),
            .init(title: "yes", didPress: {
                self.imagePreviewPresenting = false
                self.fetchRequestLoading = true
                self.deleteApiImage(filename)
            })
        ]))
    }
    
    @Published var errorFileNames: [String] = []
    
    func performSaveImage(
        data: Data, filename: String,
        completion:((_ ok: Bool)->())? = nil) {
        guard let date = data.imageDate! ?? self.files.first(where: {
                  $0.originalURL == filename
              })?.date
            else {
            completion?(false)
            return
        }
        self.photoLibraryModifierService.save(
            data: data,
            date: date) { success in
                if let completion {
                    completion(success)
                } else {
                    let title = success ? "Saved to Photos!" : "Error saving"
                    self.messages.append(.init(title: title))
                }
            }
    }
    
    func retryTask(_ task: SelectedFilesActionType?) {
        if let first = errorFileNames.first,
            let task = task ?? selectedFilesActionType {
            selectedFileIDs = Set(errorFileNames)
            errorFileNames.removeAll()
            startTask(task)
        }
    }
    
    @Published var deleteAnimating = false
    @Published var uploadAnimating = false
    @Published var saveAnimating = false
    
    func startTask(_ task: SelectedFilesActionType, confirm: Bool = false) {
        if confirm {
            self.messages.append(.init(title: "are you sure", buttons: [
                .init(title: "no"),
                .init(title: "yes", didPress: {
                    self.startTask(task)
                })
            ]))
            return
        }
        selectedFilesActionType = task
        fetchRequestLoading = true
        switch task {
        case .save:
            if let first = selectedFileIDs.first {
                saveAnimating = true
                saveImagePressed(first) { ok in
                    self.selectedFileIDs.remove(first)
                    if !ok {
                        self.errorFileNames.append(first)
                    }
                    self.startTask(task)
                }
            } else {
                withAnimation {
                    self.saveAnimating = false
                    self.fetchRequestLoading = false
                }
            }
        case .upload:
            self.upload()
        case .delete:
            if let first = selectedFileIDs.first {
                deleteAnimating = true
                deleteApiImage(first) { ok in
                    self.selectedFileIDs.remove(first)
                    if !ok {
                        self.errorFileNames.append(first)
                    }
                    self.startTask(task)
                }
            } else {
                withAnimation {
                    self.deleteAnimating = false
                    self.fetchRequestLoading = false
                }
            }
        }
    }
    
    private func saveImagePressed(
        _ filename: String,
        completion: @escaping(_ ok: Bool)->()) {
        self.loadAPIImage(filename: filename) { image in
            if let image {
                self.performSaveImage(data: image, filename: filename) { ok in
                    completion(ok)
                }
            } else {
                completion(false)
            }
            
        }
    }
    
    func loadAPIImage(filename: String, completion:@escaping(_ image: Data?)->()) {
        Task {
            WasabiService.fetchURL(
                username: "hi@mishadovhiy.com",
                filename: filename
            ) { url in
                guard let url else {
//                    self.isLoading = false
                    completion(nil)
                    return
                }
                self.loadApiImage(
                    url: url) { image in
                        completion(image)
                    }
            }
        }
    }
    
    private func loadApiImage(
        url: URL, completion: @escaping(_ image: Data?) -> ()
    ) {
        let urlTask = URLSession.shared.dataTask(with: .init(url: url)) { data, _, _ in
            DispatchQueue.main.async {
                completion(data)
            }
        }

        urlTask.resume()
    }
    
    func didSelectListItem(_ url: String) {
        if selectedFileIDs.contains(url) {
            selectedFileIDs.remove(url)
        } else {
            selectedFileIDs.insert(url)
        }
    }
    
    func presentCancelSelectionsIfNeeded() -> Bool {
        if !selectedFileIDs.isEmpty && isEditingList {
            messages.append(.init(title: "all your selected items would be removed from the memory", buttons: [
                .init(title: "yes, remove", didPress: {
                    withAnimation(.smooth) {
                        self.isEditingList.toggle()
                    }
                }),
                .init(title: "keep editing")
            ]))
            return true
        }
        return false
    }
    
    enum SelectedFilesActionType: String {
        case delete, upload, save
    }
}
