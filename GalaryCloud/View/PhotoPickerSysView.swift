//
//  PhotoPickerSysView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 04.12.2025.
//

import SwiftUI
import Combine
import Photos

struct PhotoPickerSysView: View {
    
    let completedSelection: ()->()
    private let fileManager: FileManagerService = .init()
    
    @StateObject private var manager: PhotoPickerManager = .init()
    @State private var assets: [Int: UIImage?] = [:]
    @State private var isSelected: [Int] = []
    @State var safeArea: EdgeInsets = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: safeArea.top)
            headerView
            ScrollView(content: {
                
                LazyVGrid(columns: (0..<4).compactMap({ _ in
                        .init()
                })) {
                    galaryView
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.red)
            Spacer()
                .frame(height: safeArea.bottom)
        }
        .background(.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(ViewSizeReaderModifier(safeArea: $safeArea))
    }
    
    var headerView: some View {
        HStack {
            Button("close") {
                completedSelection()
            }
            Spacer()
            Button("deselect \(manager.selectedIDs.count)") {
                manager.selectedIDs.removeAll()
            }
            Button("save \(manager.selectedIDs.count)") {
                manager.saveToTemp(manager: fileManager) {
                    completedSelection()
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 10)
        .padding(.top, 20)
    }
    @State var lastDroppedID: String?
    var galaryView: some View {
        ForEach(0..<(manager.assets?.count ?? 0), id: \.self) { i in
            VStack {
                if let image = self.assets[i],
                   let image {
                    Image(uiImage: image)
                } else {
                    LoaderView(isLoading: true)
                        .frame(width: 30, height: 30)
                    
                }
            }
            .modifier(DragAndDropModifier(disabled: false, lastDroppedID: $lastDroppedID, itemID: "\(i)", didDrop: {
                if let asset = manager.assets?.object(at: i)
                {
                    manager.select(asset: asset)
                }
            }))
            .overlay(content: {
                if isSelected.contains(i) {
                    Color.red.opacity(0.3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                        .disabled(true)
                }
            })
            .onTapGesture {
                if let asset = manager.assets?.object(at: i)
                {
                    manager.select(asset: asset)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .scaledToFit()
            .onAppear(perform: {
                if assets[i] == nil,
                   let asset = manager.assets?.object(at: i)
                {
                    manager.fetchThumb(asset) { image in
                        self.assets.updateValue(image, forKey: i)
                    }
                    if manager.selectedIDs.contains(asset) {
                        isSelected.append(i)
                    }
                    
                }
            })
            .onDisappear {
                isSelected.removeAll(where: {
                    $0 == i
                })
                assets.removeValue(forKey: i)
            }
            .onChange(of: manager.selectedIDs) { newValue in
                if let asset = manager.assets?.object(at: i)
                {
                    if manager.selectedIDs.contains(asset) {
                        isSelected.append(i)
                    } else {
                        isSelected.removeAll(where: {
                            $0 == i
                        })
                    }
                }
                
            }
        }
    }
}

class PhotoPickerManager: ObservableObject {
    
    @Published var assets: PHFetchResult<PHAsset>?
    @Published var selectedIDs: [PHAsset] = []
    
    init() {
        self.fetch()
    }
    
    func fetch() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    func select(asset: PHAsset) {
        if selectedIDs.contains(asset) {
            selectedIDs.removeAll(where: {
                $0.localIdentifier == asset.localIdentifier
            })
        } else {
            selectedIDs.append(asset)
        }
    }
    
    func saveToTemp(manager: FileManagerService,
                    completion:@escaping()->()) {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            if let asset = self.selectedIDs.first {
                print(self.selectedIDs.count, " gtrfed ")
                autoreleasepool {
                    self.assetToData(asset) { [weak self] data in
                        if let data {
                            let format: String
                            if #available(iOS 26.0, *) {
                                format = PHAssetResource.assetResources(for: asset).first?.contentType.identifier ?? "jpg"
                            } else {
                                format = PHAssetResource.assetResources(for: asset).first?.uniformTypeIdentifier ?? "jpg"
                            }
                            manager.performSave(data: data, path: asset.localIdentifier.replacingOccurrences(of: "/", with: "") + "." + format, urlType: .temporary)
                        }
                        DispatchQueue.main.async {
                            self?.selectedIDs.removeFirst()
                            self?.saveToTemp(manager: manager, completion: completion)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    private func assetToData(
        _ asset: PHAsset,
        completion: @escaping(_ data: Data?)->()) {
            guard let resource = PHAssetResource.assetResources(for: asset).first else {
                return
            }
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            let data = NSMutableData()
            PHAssetResourceManager.default().requestData(
                for: resource,
                options: options,
                dataReceivedHandler: {
                    data.append($0)
                }, completionHandler: { error in
                    if error == nil {
                        print(data.count, " yhrftgbvcghfjg ")
                        completion(data as Data)
                    } else {
                        print(error, " tregfds ")
                        completion(nil)
                    }
                })
        }
    
    func fetchThumb(_ asset: PHAsset,
                    completion: @escaping(_ image: UIImage?) -> ()) {
        let imageManager = PHCachingImageManager()
        let size: CGSize = .init(width: 50, height: 50)
        imageManager.requestImage(for: asset, targetSize: size,
                                  contentMode: .aspectFit,
                                  options: nil) { image, _ in
            completion(image)
        }
    }
}
