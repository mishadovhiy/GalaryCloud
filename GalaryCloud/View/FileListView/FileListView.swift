//
//  FileListView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct FileListView: View {
    
    @EnvironmentObject private var appData: AppData
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
                appData.message.append(.init(title: newValue.localizedDescription))
            }
        }
        .onAppear {
            viewModel.fetchList()
        }
        .fullScreenCover(isPresented: $viewModel.isPhotoLibraryPresenting) {
            PhotoLibraryPickerView { newImage in
                viewModel.photoLibrarySelectedURLs.append(contentsOf: newImage)
                viewModel.upload()
            }
        }
        .sheet(isPresented: $viewModel.imagePreviewPresenting) {
            galaryPreview
        }
    }
    
    @ViewBuilder
    var galaryPreview: some View {
        let leftInx = (viewModel.selectedImagePreviewPresenting?.index ?? 0) - 1
        let rightInx = (viewModel.selectedImagePreviewPresenting?.index ?? 0) + 1

        PhotoPreviewView(imageSelection: viewModel.selectedImagePreviewPresenting, sideImages: [
            .left: leftInx > 0 ? viewModel.files[leftInx] : nil,
            .right: rightInx <= viewModel.files.count - 1 ? viewModel.files[rightInx] : nil
        ]) { direction in
            
            let plusIndex = direction == .left ? -1 : 1
            let oldIndex = viewModel.selectedImagePreviewPresenting?.index ?? 0
            if oldIndex + plusIndex <= viewModel.files.count - 1 && oldIndex + plusIndex >= 0 {
                viewModel.selectedImagePreviewPresenting = .init(file: viewModel.files[oldIndex + plusIndex], index: oldIndex + plusIndex)
            }
        }
    }
    
    var bottomStatusBar: some View {
        HStack {
            Text("\(viewModel.totalFileRecords ?? 0)/\(viewModel.files.count)")
            Spacer()
            Button("upload") {
                viewModel.isPhotoLibraryPresenting = true
            }
            .disabled(!viewModel.photoLibrarySelectedURLs.isEmpty)
            
            Spacer()
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
        VStack(content: {
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
            Text(item.originalURL)
        })
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
