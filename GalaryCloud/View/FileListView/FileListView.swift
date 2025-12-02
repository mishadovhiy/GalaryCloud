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
                photoPickerSheet
                    .presentationBackgroundInteraction(.enabled)
                    .presentationContentInteraction(.scrolls)
            } else {
                photoPickerSheet
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
    
    var photoPickerSheet: some View {
        PhotoLibraryPickerView { newImage in
            viewModel.fetchDirectoruSizeRequest {
                viewModel.photoLibrarySelectedURLs.append(contentsOf: newImage)
                viewModel.upload()
            }
        }
        .presentationDetents([.medium, .large])
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
                TrashIconView(isLoading: viewModel.deleteAnimating) {
                    if $0 {
                        self.viewModel.selectedFilesActionType = nil
                        self.viewModel.isEditingList = false
                    }
                
                }
                .scaleEffect(1.15)
            }
            .modifier(CircularButtonModifier(isAspectRatio: true))
            .frame(maxWidth: 60)
            .aspectRatio(1, contentMode: .fit)

            .disabled(viewModel.selectedFilesActionType != nil)

            Button(action: {
                viewModel.startTask(.save)
            }, label: {
                SaveIconView(isLoading: viewModel.saveAnimating) {
                    if $0 {
                        self.viewModel.selectedFilesActionType = nil
                        self.viewModel.isEditingList = false
                    }
                }
                .scaleEffect(0.8)
                .padding(5)
            })
            .modifier(CircularButtonModifier(isAspectRatio: true))
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 60)

            .disabled(viewModel.selectedFilesActionType != nil)
            if viewModel.selectedFileIDs.isEmpty && !viewModel.errorFileNames.isEmpty {
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
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 15)
        .frame(maxWidth: viewModel.isEditingList ? 60 : nil)
        .background(content: {
            Color.clear
                .modifier(CircularButtonModifier(isAspectRatio: viewModel.isEditingList ? true : false))
                .opacity(viewModel.isEditingList ? 1 : 0)
        })
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
        HStack(alignment: .bottom) {
            Spacer()
            Button {
                viewModel.uploadFilePressed(db)
            } label: {
                UploadIconView(isLoading: viewModel.uploadAnimating)
            }
//            .frame(width: viewModel.isEditingList ? 0 : 70, height: 70)
            .disabled(viewModel.directorySizeResponse == nil)
            .modifier(CircularButtonModifier(
                isHidden: viewModel.isEditingList,
                isAspectRatio: true
            ))
            .frame(maxWidth: viewModel.isEditingList ? 0 : 70, maxHeight: 70)
            .clipped()
            .animation(.bouncy, value: viewModel.isEditingList)
            Spacer().frame(width: 10)
            HStack(spacing: 20) {
                editButton
                editingButtons
            }
            .padding(.horizontal, 15)
            .padding(.trailing, viewModel.isEditingList ? 10 : 0)
            .padding(.vertical, 5)
            .modifier(CircularButtonModifier())
            .frame(maxHeight: viewModel.isEditingList ? 70 : 45)
            .padding(.bottom, viewModel.isEditingList ? 0 : 10)
            .overlay(content: {
                HStack {
                    Spacer()
                    Text("\(viewModel.selectedFileIDs.count)")
                        .font(.footnote)
                        .minimumScaleFactor(0.3)
                        .modifier(CircularButtonModifier(isAspectRatio: true))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 20, maxHeight: 20)
                        .offset(x: 0, y: -30)
                        .opacity(viewModel.isEditingList ? 1 : 0)
                    
                }
            })
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
                    ], spacing: 8, pinnedViews: .sectionHeaders) {
//                        ForEach(viewModel.files, id: \.originalURL) { item in
//                            galaryItem(item)
//                        }
                        ForEach(viewModel.galaryData, id:\.dateString) { filesModel in
                            Section {
                                ForEach(filesModel.files,id:\.originalURL) { file in
                                    galaryItem(file)
                                }
                            } header: {
                                Text(filesModel.dateString)
                            }

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
        static let bottomStatusBarHeight: CGFloat = 60
        static let topStatusBarHeight: CGFloat = 40
    }
}

#Preview {
    FileListView()
}
