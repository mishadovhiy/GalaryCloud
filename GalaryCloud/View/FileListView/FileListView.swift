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
    @EnvironmentObject private var backgroundService: BackgroundTaskService
    
    var body: some View {
        galary
        .overlay(content: {
            statusBarOverlay
        })
        .overlay(content: {
            uploadingIndicator
        })
        .onChange(of: viewModel.uploadError) { newValue in
            if let newValue {
                viewModel.messages.append(.init(header:"Error", title: newValue.unparcedDescription))
            }
        }
        .onAppear {
            #warning("todo: check temp folder and asign to error")
            viewModel.fetchList(onAppear: true)
            withAnimation(.bouncy) {
                viewModel.appeared = true
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
        .overlay(content: {
            //tru setting view controller size to button size
            VStack {
                Spacer()
                photoPickerSheet
            }
            .ignoresSafeArea(.all)
        })
//        .onChange(of: backgroundService.currentURL) { newValue in
//            self.viewModel.temporaryDirectoryUpdated(showError: false, replacingCurrentList: true)
//        }
        .background(.black)
    }
#warning("background task on change")

    var photoPickerSheet: some View {
//        PhotoLibraryPickerView { newImage in
//            viewModel.uploadAnimating = true
//            #warning("dont fetch here")
//            viewModel.fetchDirectoruSizeRequest {
////                viewModel.photoLibrarySelectedURLs.append(contentsOf: newImage)
////                viewModel.upload()
//                viewModel.temporaryDirectoryUpdated(showError: true, replacingCurrentList: true)
//                #warning("background task")
////                self.backgroundService.scheduleTask()
//            }
//        }
//        .presentationDetents([.large])
        PhotoPickerSysView {
            //            viewModel.uploadAnimating = true
            viewModel.temporaryDirectoryUpdated(showError: true, replacingCurrentList: false)
            withAnimation {
                viewModel.isPhotoLibraryPresenting = false
            }
        }
        .frame(maxHeight: viewModel.isPhotoLibraryPresenting ? .infinity : 0)
        .animation(.bouncy, value: viewModel.isPhotoLibraryPresenting)
        .clipped()
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
            if viewModel.fetchRequestLoading {
                
                HStack {
                    Spacer()
                    LoaderView(isLoading: viewModel.fetchRequestLoading)
                        .frame(width: 10)
                }
            }
            Spacer()
            bottomStatusBar
            Spacer()
                .frame(height: !viewModel.photoLibrarySelectedURLs.isEmpty ? viewModel.uploadIndicatorSize.height : 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        .animation(.bouncy, value: viewModel.photoLibrarySelectedURLs)

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
    
    var closeButton: some View {
        MenuIconShape(type: .close)
            .stroke(.primaryText, lineWidth: 3)
            .frame(width: viewModel.isEditingList ? 15 : 0, height: 15)
            .offset(x: 1, y: 2)
            .clipped()
    }
    
    var editButton: some View {
        Button(action: {
            if viewModel.presentCancelSelectionsIfNeeded() {
                return
            }
            withAnimation(.smooth) {
                self.viewModel.isEditingList.toggle()
            }
        }, label: {
            HStack(spacing: 0) {
                ZStack {
                    closeButton
                        .blendMode(.destinationOut)
                    closeButton
                        .opacity(0.2)
                }
                Text("Select")
                    .frame(maxWidth: viewModel.isEditingList ? 0 : nil)
            }
        })
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 15)
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
                    Text(error.unparcedDescription)
                        .modifier(ErrorViewModifier())
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
            HStack(spacing: !viewModel.appeared ? 1000 : 10) {
                editButton
                editingButtons
            }
            .animation(.bouncy, value: viewModel.appeared)
            .padding(.horizontal, 5)
            .padding(.trailing, viewModel.isEditingList ? 7 : 0)
            .padding(.vertical, 5)
            .modifier(CircularButtonModifier())
            .compositingGroup()
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
    }
    @ViewBuilder
    var uploadingIndicator: some View {
        VStack {
            Spacer()
            if !viewModel.photoLibrarySelectedURLs.isEmpty || !viewModel.errorFileNames.isEmpty {
                let firstErrorURL = URL(string: viewModel.errorFileNames.first ?? "")
                let count = viewModel.photoLibrarySelectedURLs.count
                let uploadingCount = count == 0 ? viewModel.errorFileNames.count : count
                let currentURL = (viewModel.photoLibrarySelectedURLs.first ?? firstErrorURL)!
                UploadingProgressView(currentItem: currentURL, uploadingFilesCount: uploadingCount, error: viewModel.uploadError, resendPressed: {
                    viewModel.photoLibrarySelectedURLs.append(contentsOf: viewModel.errorFileNames.compactMap({.init(string: $0)!}))
#warning("background task")
//                    backgroundService.scheduleTask()
                    viewModel.upload()
                })
                .modifier(ViewSizeReaderModifier(viewSize: $viewModel.uploadIndicatorSize))
            }
        }
    }
    
    var galary: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    if !viewModel.fetchRequestLoading && viewModel.files.isEmpty {
                        NoDataView(text: "Start uploading photos", image: .emptyGalary)
                            .padding(.top, 150)
                            .animation(.bouncy, value: viewModel.files.isEmpty)
                            .transition(.move(edge: .bottom))
                    }
                    LazyVGrid( columns: [
                        .init(), .init(), .init(), .init()
                    ], spacing: viewModel.appeared ? 8 : 120, pinnedViews: .sectionHeaders) {
                        ForEach(viewModel.galaryData, id:\.dateString) { filesModel in
                            Section {
                                ForEach(filesModel.files,id:\.originalURL) { file in
                                    galaryItem(file)
                                }
                            } header: {
                                HStack {
                                    ZStack(content: {
                                        Text(filesModel.dateString)
                                            .blendMode(.destinationOut)
                                        Text(filesModel.dateString)
                                            .opacity(0.2)
                                    })
                                    .foregroundColor(.primaryText)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .modifier(CircularButtonModifier())
                                        .compositingGroup()
                                    Spacer()
                                }
                            }

                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, Constants.bottomStatusBarHeight)
                    Spacer()
                        .frame(height: !viewModel.photoLibrarySelectedURLs.isEmpty ? viewModel.uploadIndicatorSize.height : 0)
                        .animation(.bouncy, value: viewModel.photoLibrarySelectedURLs.isEmpty)
                }
                .animation(.bouncy, value: viewModel.appeared)
            }
            .refreshable {
                viewModel.fetchList(ignoreOffset: true, reload: true)
            }
            
        }

    }
    
    private func galaryItem(_ item: FileListViewModel.File) -> some View {
        GeometryReader(content: { proxy in
            CachedAsyncImage(
                presentationType: .galary(.init(username: KeychainService.username,
                              fileName: item.originalURL,
                                                date: item.date))
            )
            .frame(width: proxy.size.width, height: proxy.size.width)
            .clipped()
            .overlay {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("\(DateComponents(string: item.date).day ?? 0)")
                        .blendMode(.destinationOut)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 7, weight: .medium))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .modifier(CircularButtonModifier(maxHeight: nil))
                        .compositingGroup()
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                Color.red.opacity(0.3)
                    .allowsHitTesting(false)
                    .disabled(true)
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
