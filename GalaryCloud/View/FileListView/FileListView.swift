//
//  FileListView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct FileListView: View {
    
    @StateObject private var viewModel: FileListViewModel = .init()
    
    var body: some View {
        VStack(content: {
            if let error = viewModel.fetchError {
                Text(error.localizedDescription)
            }
            galary
            
            bottomStatusBar
        })
        .padding(.bottom, !viewModel.photoLibrarySelectedURLs.isEmpty ? viewModel.uploadIndicatorSize.height : 0)
        .overlay(content: {
            uploadingIndicator
        })
        .onChange(of: viewModel.uploadError) { newValue in
            if let newValue {
                viewModel.messages.append(.init(title: newValue.localizedDescription))
            }
        }
        .onAppear {
            viewModel.fetchList()
        }
        .fullScreenCover(isPresented: $viewModel.isPhotoLibraryPresenting) {
            PhotoLibraryPickerView { newImage in
                viewModel.fetchDirectoruSizeRequest {
                    viewModel.photoLibrarySelectedURLs.append(contentsOf: newImage)
                    viewModel.upload()
                }
            }
        }
        .sheet(isPresented: $viewModel.storeKitPresenting, content: {
            StoreKitView()
        })
        .sheet(isPresented: $viewModel.imagePreviewPresenting) {
            galaryPreview
        }
        .modifier(AlertModifier(messages: $viewModel.messages))
    }
    
    @ViewBuilder
    var galaryPreview: some View {
        let inx = viewModel.selectedImagePreviewPresenting?.index ?? 0
        PhotoPreviewView(imageSelection: viewModel.selectedImagePreviewPresenting, sideImages: [
            .left: inx - 1 > 0 ? viewModel.files[inx - 1] : nil,
            .right: inx + 1 <= viewModel.files.count - 1 ? viewModel.files[inx + 1] : nil
        ], didDeleteImage: {
            print("deletePressed")
            viewModel.files.remove(at: inx)
            viewModel.imagePreviewPresenting = false
        }) { direction in
            let inx = viewModel.selectedImagePreviewPresenting?.index ?? 0

            let plusIndex = direction == .left ? -1 : 1
            let isValid = inx + plusIndex <= viewModel.files.count - 1 && inx + plusIndex >= 0
            if isValid {
                viewModel.selectedImagePreviewPresenting = .init(file: viewModel.files[inx + plusIndex], index: inx + plusIndex)
            }
        }
    }
    
    var bottomStatusBar: some View {
        HStack {
            Text("\(viewModel.totalFileRecords ?? 0)/\(viewModel.files.count)")
            Button("upgrade") {
                viewModel.storeKitPresenting = true
            }
            Spacer()
            Button("upload") {
                viewModel.isPhotoLibraryPresenting = true
            }
            .disabled(!viewModel.photoLibrarySelectedURLs.isEmpty)
            
            Spacer()
            Text("b:\(viewModel.directorySizeResponse?.megabytes ?? "")")
                .padding(.trailing, 5)
            if viewModel.fetchRequestLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
    
    var uploadingIndicator: some View {
        VStack {
            Spacer()
            if !viewModel.photoLibrarySelectedURLs.isEmpty {
                UploadingProgressView(uploadingFilesCount: viewModel.photoLibrarySelectedURLs.count, error: viewModel.uploadError, resendPressed: {
                    viewModel.upload()
                })
                .modifier(ViewSizeReaderModifier(viewSize: $viewModel.uploadIndicatorSize))
            }
        }
    }
    
    var galary: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [.init(), .init()]) {
                ForEach(viewModel.files, id: \.originalURL) { item in
                    galaryItem(item)
                }
            }
            .refreshable {
                viewModel.fetchList(ignoreOffset: true)
            }
        }
    }
    
    private func galaryItem(_ item: FileListViewModel.File) -> some View {
        CachedAsyncImage(
            presentationType: .galary(.init(username: "hi@mishadovhiy.com",
                          fileName: item.originalURL))
        )
        .frame(height: 200)
        .onTapGesture {
            viewModel.selectedImagePreviewPresenting = .init(file: item, index: viewModel.files.firstIndex(where: {
                $0.originalURL == item.originalURL
            })!)
        }
        .onAppear {
            if viewModel.files.last?.originalURL == item.originalURL {
                viewModel.fetchList()
            }
        }
    }
}

#Preview {
    FileListView()
}
