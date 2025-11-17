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
            List(viewModel.files, id: \.originalURL) { item in
                Text(item.originalURL)
                    .onAppear {
                        if viewModel.files.last?.originalURL == item.originalURL {
                            viewModel.fetchList()
                        }
                    }
            }
            HStack {
                Text("\(viewModel.totalFileRecords ?? 0)")
                Spacer()
                NavigationLink {
                    PhotoLibraryPickerView { newImage in
                        viewModel.photoLibrarySelectedURLs.append(contentsOf: newImage)
                    }
                } label: {
                    Text("upload")
                }
                .disabled(viewModel.uploadRequestLoading)

                Spacer()
                if viewModel.fetchRequestLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        })
        .padding(.bottom, viewModel.uploadRequestLoading ? viewModel.uploadIndicatorSize.height : 0)
        .overlay(content: {
            VStack {
                Spacer()
                if viewModel.uploadRequestLoading {
                    UploadingProgressView(uploadingFilesCount: 0, error: viewModel.uploadError, resendPressed: {
                        viewModel.upload(files: nil, reUploading: true)
                    })
                    .modifier(ViewSizeReaderModifier(viewSize: $viewModel.uploadIndicatorSize))
                }
            }
        })
        .onChange(of: viewModel.uploadError) { newValue in
            if let newValue {
                appData.message.append(.init(title: newValue.localizedDescription))
                viewModel.uploadError = nil
            }
        }
        .onAppear {
            viewModel.fetchList()
        }
    }
}

#Preview {
    FileListView()
}
