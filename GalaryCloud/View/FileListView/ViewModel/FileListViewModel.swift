//
//  FileListViewModel.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Combine
import SwiftUI

class FileListViewModel: ObservableObject {
    
    @Published var files: [FetchFilesResponse.File] = []
    
    @Published var fetchError: NSError?
    @Published var uploadError: NSError?
    
    @Published var fetchRequestLoading: Bool = false
    @Published var uploadRequestLoading: Bool = false
    @Published var uploadIndicatorSize: CGSize = .zero
    private var requestOffset: Int = 0
    private var selectedUploadingFiles: [CreateFileRequest.Image] = []
    
    var totalFileRecords: Int?
    
    func fetchList(ignoreOffset: Bool = false) {
        if fetchRequestLoading {
            print("request is already loading")
            return
        }
        if let totalFileRecords,
           !ignoreOffset, totalFileRecords <= files.count {
            print("no more records")
            return
        }
        fetchRequestLoading = true
        Task(priority: .userInitiated) {
            let response = await URLSession.shared.resumeTask(FetchFilesRequest(offset: requestOffset, username: "hi@mishadovhiy.com"))
            
            await MainActor.run {
                switch response {
                    
                case .success(let result):
                    var canUpdateData = false
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
                    }
                    print(canUpdateData, " htrgerfds ")
                    self.fetchRequestLoading = false
                    
                case .failure(let error):
                    self.fetchError = error as NSError
                    self.fetchRequestLoading = false
                }
            }
        }
    }
    
    func upload(files: [CreateFileRequest.Image]?, reUploading: Bool = false) {
        if uploadRequestLoading {
            return
        }
        uploadRequestLoading = true
        let files = files ?? selectedUploadingFiles
        if files.isEmpty {
            print("no files to upload")
            return
        }
        Task(priority: .userInitiated) {
            let response = await URLSession.shared.resumeTask(CreateFileRequest(username: "hi@mishadovhiy.com", originalURL: files))
            
            await MainActor.run {
                switch response {
                    
                case .success(let result):
                    uploadRequestLoading = false
                    if result.success {
                        selectedUploadingFiles.removeAll()
                        self.fetchList(ignoreOffset: true)
                    } else if !reUploading {
                        self.selectedUploadingFiles = files
                    }
                    
                case .failure(let error):
                    uploadRequestLoading = false
                    if !reUploading {
                        self.selectedUploadingFiles = files
                    }
                }
            }
        }
    }
}
