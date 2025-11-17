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
                print(viewModel.photoLibrarySelectedURLs, " jufredws ")
            }
        }
        .sheet(isPresented: $viewModel.imagePreviewPresenting) {
#warning("todo: image preview view, with delete")
            VStack {
                if let image = viewModel.selectedImagePreviewPresenting {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .background(.black)
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
        //        List(viewModel.files, id: \.originalURL) { item in
        //
        //        }
        //        .refreshable {
        //            viewModel.fetchList(ignoreOffset: true)
        //        }
    }
    
    private func galaryItem(_ item: FileListViewModel.File) -> some View {
        VStack(content: {
            CachedAsyncImage(
                username: "hi@mishadovhiy.com",
                fileName: item.originalURL,
                imagePresenting: $viewModel.selectedImagePreviewPresenting
            )
            .frame(height: 200)
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
