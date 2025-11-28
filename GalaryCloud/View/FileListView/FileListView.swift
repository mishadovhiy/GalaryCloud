//
//  FileListView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct FileListView: View {
    
    @StateObject private var viewModel: FileListViewModel = .init()
    @EnvironmentObject private var db: DataBaseService
    
    var body: some View {
        galary
        .overlay(content: {
            statusBarOverlay
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
        .sheet(isPresented: $viewModel.isPhotoLibraryPresenting) {
            if #available(iOS 16.4, *) {
                PhotoLibraryPickerView { newImage in
                    viewModel.fetchDirectoruSizeRequest {
                        viewModel.photoLibrarySelectedURLs.append(contentsOf: newImage)
                        viewModel.upload()
                    }
                }
                    .presentationDetents([.medium, .large])
                    .presentationBackgroundInteraction(.enabled)
                    .presentationContentInteraction(.scrolls)
            } else {
                PhotoLibraryPickerView { newImage in
                    viewModel.fetchDirectoruSizeRequest {
                        viewModel.photoLibrarySelectedURLs.append(contentsOf: newImage)
                        viewModel.upload()
                    }
                }
                    .presentationDetents([.medium, .large])
            }
        }

        .sheet(isPresented: $viewModel.imagePreviewPresenting) {
            galaryPreview
        }
        .onChange(of: viewModel.messages) { newValue in
            if !newValue.isEmpty {
                db.messages.append(contentsOf: newValue)
                viewModel.messages.removeAll()
            }
        }
        .onChange(of: viewModel.directorySizeResponse?.bytes) { newValue in
            db.storageUsed = newValue ?? 0
        }
        .onChange(of: viewModel.totalFileRecords) { newValue in
            guard let newValue else {
                return
            }
            db.totalFileCount = newValue
        }
        .background(.red)
    }
    
    @ViewBuilder
    var galaryPreview: some View {
        let inx = viewModel.selectedImagePreviewPresenting?.index ?? 0
        PhotoPreviewView(imageSelection: viewModel.selectedImagePreviewPresenting, sideImages: [
            .left: inx - 1 > 0 ? viewModel.files[inx - 1] : nil,
            .right: inx + 1 <= viewModel.files.count - 1 ? viewModel.files[inx + 1] : nil
        ], deleteImagePressed: {
            guard let filename = viewModel.selectedImagePreviewPresenting?.file.originalURL else {
                return
            }
            self.viewModel.deletePressed(filename: filename)
        }) { direction in
            let inx = viewModel.selectedImagePreviewPresenting?.index ?? 0

            let plusIndex = direction == .left ? -1 : 1
            let isValid = inx + plusIndex <= viewModel.files.count - 1 && inx + plusIndex >= 0
            if isValid {
                viewModel.selectedImagePreviewPresenting = .init(file: viewModel.files[inx + plusIndex], index: inx + plusIndex)
            }
        }
    }
    
    var statusBarOverlay: some View {
        VStack {
            topStatusBarBar
            Spacer()
            bottomStatusBar
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        
    }
    
    var topStatusBarBar: some View {
        HStack {
            Spacer().frame(width: 100)
            if !viewModel.files.isEmpty {
                Button(viewModel.isEditingList ? "cancel" : "Edit") {
                    if viewModel.presentCancelSelectionsIfNeeded() {
                        return
                    }
                    withAnimation(.smooth) {
                        self.viewModel.isEditingList.toggle()
                    }
                }
            }
        
            Spacer()
            if viewModel.isEditingList {
                Button {
                    viewModel.startTask(.delete, confirm: true)

                } label: {
                    HStack {
                        TrashIconView(isLoading: viewModel.deleteAnimating) {
                            if $0 {
                                self.viewModel.selectedFilesActionType = nil
                                self.viewModel.isEditingList = false
                            }
                        
                        }
                        Text("\(viewModel.selectedFileIDs.count)")
                    }
                }
                .background(.blue.opacity(0.15))
                .tint(.blue)
                .disabled(viewModel.selectedFilesActionType != nil || !viewModel.photoLibrarySelectedURLs.isEmpty)
                Spacer().frame(width: 50)

                Button(action: {
                    viewModel.startTask(.save)
                }, label: {
                    HStack {
                        SaveIconView(isLoading: viewModel.saveAnimating) {
                            if $0 {
                                self.viewModel.selectedFilesActionType = nil
                                self.viewModel.isEditingList = false
                            }
                        }
                        Text("\(viewModel.selectedFileIDs.count)")
                    }
                })
                .background(.blue.opacity(0.15))
                .tint(.blue)
                .disabled(viewModel.selectedFilesActionType != nil || !viewModel.photoLibrarySelectedURLs.isEmpty)
                Spacer().frame(width: 50)
                if viewModel.selectedFileIDs.isEmpty && !viewModel.errorFileNames.isEmpty {
                    Button("Error \(viewModel.selectedFilesActionType?.rawValue ?? "?") \(viewModel.errorFileNames.count)") {
                        viewModel.retryTask(nil)
                    }
                }
                
            }
            Spacer()
        }
        .frame(height: Constants.topStatusBarHeight)
        .overlay {
            if let error = viewModel.fetchError {
                VStack {
                    Spacer().frame(height: Constants.topStatusBarHeight)
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    var bottomStatusBar: some View {
        HStack {
            Button {
                viewModel.isPhotoLibraryPresenting = true
            } label: {
                UploadIconView(isLoading: viewModel.uploadAnimating)
            }
            .disabled(!viewModel.photoLibrarySelectedURLs.isEmpty)
            .background(.white)
            .tint(.blue)
            .frame(width: Constants.bottomStatusBarHeight, height: Constants.bottomStatusBarHeight)
            .cornerRadius(Constants.bottomStatusBarHeight / 2)
            .overlay {
                RoundedRectangle(cornerRadius: Constants.bottomStatusBarHeight / 2)
                    .stroke(.blue, lineWidth: 1.5)
            }
            .shadow(radius: 8)
        }
        .overlay {
            HStack {
                Spacer()
                if viewModel.fetchRequestLoading {
                    Text("\(viewModel.totalFileRecords ?? 0)/\(viewModel.files.count)")
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
        .frame(height: Constants.bottomStatusBarHeight)
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
        VStack {
            ScrollView(.vertical) {
                VStack(content: {
                    Spacer()
                        .frame(height: Constants.topStatusBarHeight)
                    LazyVGrid(columns: [.init(), .init()]) {
                        ForEach(viewModel.files, id: \.originalURL) { item in
                            galaryItem(item)
                        }
                        
                    }
                    Spacer()
                        .frame(height: Constants.bottomStatusBarHeight)
                })
            }
            .refreshable {
                viewModel.fetchList(ignoreOffset: true, reload: true)
            }
            Spacer()
                .frame(maxHeight: viewModel.isPhotoLibraryPresenting ? .infinity : 0)
                .animation(.bouncy, value: viewModel.isPhotoLibraryPresenting)
        }
        .ignoresSafeArea(.all)

    }
    
    private func galaryItem(_ item: FileListViewModel.File) -> some View {
        CachedAsyncImage(
            presentationType: .galary(.init(username: "hi@mishadovhiy.com",
                          fileName: item.originalURL,
                                            date: item.date))
        )
        .frame(height: 200)
        .onTapGesture {
            if !viewModel.isEditingList {
                viewModel.selectedImagePreviewPresenting = .init(file: item, index: viewModel.files.firstIndex(where: {
                    $0.originalURL == item.originalURL
                })!)
            } else {
                viewModel.didSelectListItem(item.originalURL)
            }
        }
        .overlay(content: {
            if viewModel.selectedFileIDs.contains(item.originalURL) {
                Color.red.opacity(0.5)
            }
        })
        .modifier(DragAndDropModifier(disabled: !viewModel.isEditingList, lastDroppedID: $viewModel.lastDroppedID, itemID: item.originalURL, didDrop: {
            viewModel.didSelectListItem(item.originalURL)
        }))
        .onAppear {
            if viewModel.files.last?.originalURL == item.originalURL {
                viewModel.fetchList()
            }
        }
    }
}

extension FileListView {
    struct Constants {
        static let bottomStatusBarHeight: CGFloat = 50
        static let topStatusBarHeight: CGFloat = 40
    }
}

#Preview {
    FileListView()
}
