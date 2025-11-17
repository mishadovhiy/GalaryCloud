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
    
    var galary: some View {

        List(viewModel.files, id: \.originalURL) { item in
            VStack(content: {
                image
                Text(item.originalURL)
            })
                .onAppear {
                    if viewModel.files.last?.originalURL == item.originalURL {
                        viewModel.fetchList()
                    }
                }
        }
    }
    
    var body: some View {
        VStack(content: {
            if let error = viewModel.fetchError {
                Text(error.localizedDescription)
            }
            galary

            HStack {
                Text("\(viewModel.totalFileRecords ?? 0)")
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
        })
        .padding(.bottom, !viewModel.photoLibrarySelectedURLs.isEmpty ? viewModel.uploadIndicatorSize.height : 0)
        .overlay(content: {
            VStack {
                Spacer()
                if !viewModel.photoLibrarySelectedURLs.isEmpty {
                    UploadingProgressView(uploadingFilesCount: viewModel.photoLibrarySelectedURLs.count, error: viewModel.uploadError, resendPressed: {
                        viewModel.upload()
                    })
                    .modifier(ViewSizeReaderModifier(viewSize: $viewModel.uploadIndicatorSize))
                }
            }
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
    }
}

#Preview {
    FileListView()
}
