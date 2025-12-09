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
    struct FileSection {
        let dateString: String
        let files: [File]
    }
    @Published var appeared = false
    @Published var galaryData: [FileSection] = []
    @Published var files: [File] = [] {
        didSet {
            groupFiles()
        }
    }
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
    private let filemamager = FileManagerService()
    @Published var selectedFilesActionType: SelectedFilesActionType?
    @Published var lastSelectedID: String?
    private var requestOffset: Int = 0
#if !os(watchOS)
    private let photoLibraryModifierService = PHPhotoLibraryModifierService()
    #endif
    var totalFileRecords: Int?
    
    func fetchDirectoruSizeRequest(completion:(()->())? = nil) {
        Task(priority: .low) {
            let response = await URLSession.shared.resumeTask(DirectorySizeRequest(path: KeychainService.username))
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
    
    func groupFiles() {
        DispatchQueue(label: "", qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let dict = Dictionary(grouping: files, by: {
                let date = Calendar.current.dateComponents([.year, .month], from: Date(string: $0.date))
                return "\(date.year ?? 0).\(date.month ?? 0)"
            })
            var result = galaryData
            result.removeAll()
            dict.keys.sorted(by: {
                let comp1 = $0.components(separatedBy: ".").compactMap({Int($0)})
                let comp2 = $1.components(separatedBy: ".").compactMap({Int($0)})

                let date1 = Calendar.current.date(from: .init(year: comp1.first, month: comp1.last))
                let date2 = Calendar.current.date(from: .init(year: comp2.first, month: comp2.last))

                return date1 ?? .now > date2 ?? .now
            }).forEach { key in
                result.append(.init(dateString: key, files: dict[key] ?? []))
            }
            DispatchQueue.main.async { [weak self] in
                self?.galaryData = result
            }
        }
    }
    
    func fetchList(ignoreOffset: Bool = false, reload: Bool = false, onAppear: Bool = false) {
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
        Task(name: "fetchlist", priority: .high) {
            let response = await URLSession.shared.resumeTask(FetchFilesRequest(offset: requestOffset, username: KeychainService.username))
            
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
                    if onAppear {
                        temporaryDirectoryUpdated(showError: true, replacingCurrentList: true)
                    }
                case .failure(let error):
                    self.fetchError = error as NSError
                }
            }
        }
    }
    
    func temporaryDirectoryUpdated(showError: Bool = false, replacingCurrentList: Bool = false) {
        let errorURLs = filemamager.loadFiles(.temporary)
        print(errorURLs.count, " yrefds")
        if !errorURLs.isEmpty {
            if selectedFilesActionType == nil {
                selectedFilesActionType = .upload
            }
            if showError {
                self.uploadError = .init(domain: "retry uploading files", code: 10)
            }
            if !uploadAnimating {
                uploadAnimating = true
            }
            if replacingCurrentList {
                photoLibrarySelectedURLs = errorURLs
            } else {
                photoLibrarySelectedURLs.append(contentsOf: errorURLs)
            }
        }
    }

    func didCompletedUploadingFiles() {
        self.requestOffset = 0
        self.files.removeAll()
        self.directorySizeResponse = nil
        filemamager.clear()
        self.fetchList(ignoreOffset: true)
        self.uploadAnimating = false
    }
    
    func uploadFilePressed(_ db: DataBaseService) {
        Task {
            await db.storeKitService.fetchActiveProducts()
            let gbUser = (self.directorySizeResponse?.bytes.megabytesFromBytes ?? 0) / 1000
            print(gbUser, "gb used")
            if Double(db.storeKitService.activeSubscriptionGB) >= gbUser {
                await MainActor.run {
                    withAnimation(.bouncy) {
                        self.isPhotoLibraryPresenting = true
                    }
                }
            } else {
                await MainActor.run {
                    self.messages.append(.init(header:"Error", title: "Storage limit increesed, upgrade to pro to proceed", buttons: [
                        .init(title: "cancel")
                    ]))
                }
            }
        }
    }
    
    func upload() {
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
        Task(name: "uploading", priority: .utility) {
            let response = await URLSession.shared.resumeTask(CreateFileRequest(username: KeychainService.username, originalURL: [apiData]))
            
            await MainActor.run {
                switch response {
                    
                case .success(_):
                    filemamager.performDelete(path: url.lastPathComponent, urlType: .temporary)
                    self.photoLibrarySelectedURLs.removeFirst()
                    if photoLibrarySelectedURLs.isEmpty {
                        self.didCompletedUploadingFiles()
                    } else {
                        self.files.insert(.init(originalURL: url.lastPathComponent, date: date ?? Date().string), at: 0)
                        self.upload()
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
            Task(name: "deleting", priority: .utility) {
            let request = await URLSession.shared.resumeTask(DeleteFileRequest(username: KeychainService.username, filename: filename))
            filemamager.delete(path: KeychainService.username + filename)
            await MainActor.run {
//                isLoading = false
                let errorMessage: String?
                switch request {
                    
                case .success(let data):
                    errorMessage = data.success ? nil : "error deleting image"
                    
                case .failure(let error):
                    errorMessage = error.unparcedDescription
                    
                }
                if let completed {
                    self.files.removeAll(where: {
                        $0.originalURL == filename
                    })
                    completed(errorMessage == nil)
                } else {
                    messages.append(.init(header:errorMessage == nil ? "Success" : "Error", title: errorMessage ?? "Image Deleted", buttons: [
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
        messages.append(.init(title: "are you sure you want to delete photo?", buttons: [
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
#if !os(watchOS)
        self.photoLibraryModifierService.save(
            data: data,
            date: date) { success in
                if let completion {
                    completion(success)
                } else {
                    let title = success ? "Saved to Photos!" : "Error saving"
                    self.messages.append(.init(header:success ? "Success" : "Error", title: title))
                }
            }
            #endif
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
            self.messages.append(.init(title: "Are you sure", buttons: [
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
        Task(name:"loadImage", priority: .utility) {
            let response = await URLSession.shared.resumeTask(FetchImageRequest(username: KeychainService.username, filename: filename))
            let imageData = try? response.get()
            await MainActor.run {
                completion(imageData)
            }
        }
    }
    
    /// not used
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
    
    var showingUploading: Bool {
        [!photoLibrarySelectedURLs.isEmpty,
         !errorFileNames.isEmpty,
         uploadError != nil
        ].contains(true)
    }
    
    func didSelectListItem(_ url: String, onScroll: Bool = false) {
        guard let i = self.files.firstIndex(where: {
            $0.originalURL == url
        }) else {
            print("notfound")
            return
        }
        var selectedFileIDs = selectedFileIDs
        let newArray: [Int]
        if onScroll,
            let lastSelectedID,
            lastSelectedID != url,
           let lastSelectedIndex = files.firstIndex(where: {
               $0.originalURL == lastSelectedID
           })
        {
            print("lastlast: ", lastSelectedID, " ferwda ", i)
            if lastSelectedIndex > i {
                newArray = Array(i..<lastSelectedIndex)
            } else {
                newArray = Array(lastSelectedIndex..<i)
            }
            
        } else {
            newArray = [i]
        }
        
        let dataArray = newArray.compactMap({
            files[$0].originalURL
        })
        let containsInSelected = selectedFileIDs.contains(files[i].originalURL)
        dataArray.forEach {
            if containsInSelected {
                selectedFileIDs.remove($0)

            } else {
                selectedFileIDs.insert($0)
            }
        }
        
        self.selectedFileIDs = selectedFileIDs
        if onScroll {
            lastSelectedID = url
        } else {
            lastSelectedID = nil
        }
    }
    
    func presentCancelSelectionsIfNeeded() -> Bool {
        if !selectedFileIDs.isEmpty && isEditingList {
            messages.append(.init(header:"Confirmation", title: "all your selected items would be removed from the memory", buttons: [
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
