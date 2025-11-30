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
        .background(.black)
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
//            topStatusBarBar
            Spacer()
            bottomStatusBar
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        
    }
    
    @ViewBuilder
    var editingButtons: some View {
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
            .tint(.blue)
            .padding(.horizontal, 10)
            .background(.white)

            .disabled(viewModel.selectedFilesActionType != nil)
            Spacer().frame(width: 40)

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
            .tint(.blue)
            .padding(.horizontal, 10)
            .background(.white)
            .disabled(viewModel.selectedFilesActionType != nil)
            if viewModel.selectedFileIDs.isEmpty && !viewModel.errorFileNames.isEmpty {
                Spacer().frame(width: 40)
                Button("Error \(viewModel.errorFileNames.count)") {
                    viewModel.selectedFileIDs = Set(viewModel.errorFileNames)
                    viewModel.errorFileNames.removeAll()
                }
            }
            
        }
    }
    var editButton: some View {
        Button(!viewModel.isEditingList ? "edit" : "X") {
            if viewModel.presentCancelSelectionsIfNeeded() {
                return
            }
            withAnimation(.smooth) {
                self.viewModel.isEditingList.toggle()
            }
        }
        .padding(.horizontal, 15)
        .modifier(CircularButtonModifier())
        .animation(.smooth, value: viewModel.isEditingList)
    }
    
    var topStatusBarBar: some View {
        HStack {
            Spacer().frame(width: 100)
            if !viewModel.files.isEmpty {
                
            }
        
            Spacer()
            
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
            Spacer()
            Button {
                viewModel.uploadAnimating.toggle()
//                viewModel.isPhotoLibraryPresenting = true
            } label: {
                UploadIconView(isLoading: viewModel.uploadAnimating)
            }
            .modifier(CircularButtonModifier(
                width: viewModel.isEditingList ? 0 : 70,
                height: 70
            ))
            .animation(.bouncy, value: viewModel.isEditingList)
            Spacer().frame(width: 40)
            editButton
            editingButtons
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
                    LazyVGrid( columns: [
                        .init(), .init(), .init(), .init()
                    ], spacing: 8) {
                        ForEach(viewModel.files, id: \.originalURL) { item in
                            galaryItem(item)
                        }
                        
                    }
                    Spacer()
                        .frame(height: Constants.bottomStatusBarHeight)
                })
                .padding(.horizontal, 4)
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
        GeometryReader(content: { proxy in
            CachedAsyncImage(
                presentationType: .galary(.init(username: "hi@mishadovhiy.com",
                              fileName: item.originalURL,
                                                date: item.date))
            )
            .frame(width: proxy.size.width, height: proxy.size.width)
            .clipped()

        })
        .aspectRatio(1, contentMode: .fill)
        .cornerRadius(4)
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
