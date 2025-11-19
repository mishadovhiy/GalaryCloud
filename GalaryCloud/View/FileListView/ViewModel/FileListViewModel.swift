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
    private var requestOffset: Int = 0
    
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
    
    func upload() {
        self.uploadError = nil
        guard let url = self.photoLibrarySelectedURLs.first else {
            return
        }

        guard let imageData = try? Data(contentsOf: url) else {
            if !self.photoLibrarySelectedURLs.isEmpty {
                self.photoLibrarySelectedURLs.removeFirst()
            }
            return
        }
        
        let apiData = CreateFileRequest.Image(url: url.lastPathComponent, date: Date().string, data: imageData.base64EncodedString())
        Task(priority: .userInitiated) {
            let response = await URLSession.shared.resumeTask(CreateFileRequest(username: "hi@mishadovhiy.com", originalURL: [apiData]))
            
            await MainActor.run {
                switch response {
                    
                case .success(let result):
                    if result.success {
                        self.photoLibrarySelectedURLs.removeFirst()
                        if photoLibrarySelectedURLs.isEmpty {
                            self.requestOffset = 0
                            self.files.removeAll()
                            self.directorySizeResponse = nil
                            self.fetchList(ignoreOffset: true)

                        } else {
                            self.upload()
                        }
                    }
                    
                case .failure(let error):
                    self.uploadError = error as NSError
                }
            }
        }
    }
}
