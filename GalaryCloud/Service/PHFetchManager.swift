//
//  PhotoPickerManager.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 05.12.2025.
//

import Foundation
import Photos
import Combine
import UIKit

class PHFetchManager: ObservableObject {
    
    @Published var assets: PHFetchResult<PHAsset>?
    @Published var lastSelectedID: Int?
    @Published var selectedIs: [Int] = []
    @Published var saving: Bool = false

    init() {
        self.fetch()
    }
    
    func fetch() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    func selectI(_ i: Int, onScroll: Bool = false) {
        if saving {
            return
        }
        var selectedIs = selectedIs
        let newArray: [Int]
        if onScroll, let lastSelectedID, lastSelectedID != i {
            print("lastlast: ", lastSelectedID, " ferwda ", i)
            if lastSelectedID > i {
                newArray = Array(i..<lastSelectedID)
            } else {
                newArray = Array(lastSelectedID..<i)
            }
            
        } else {
            newArray = [i]
        }
        if selectedIs.contains(i) {
            newArray.forEach { removeI in
                selectedIs.removeAll(where: {$0 == removeI})
            }
        } else {
            selectedIs.append(contentsOf: newArray)
        }
        
        self.selectedIs = Array(Set(selectedIs))
        if onScroll {
            lastSelectedID = i
        } else {
            lastSelectedID = nil
        }
    }
    
    func saveToTemp(manager: FileManagerService,
                    completion:@escaping()->()) {
        DispatchQueue(label: "db", qos: .userInitiated).async { [weak self] in
            guard let self else {
                return
            }
            if let index = self.selectedIs.first,
               let asset = self.assets?.object(at: index)
            {
                print(self.selectedIs.count, " gtrfed ", Date())
                autoreleasepool {
                    self.assetToData(asset) { [weak self] data in
                        if let data {
                            let format: String
                            if #available(iOS 26.0, tvOS 26.0, *) {
                                format = PHAssetResource.assetResources(for: asset).first?.contentType.identifier ?? "jpg"
                            } else {
                                format = PHAssetResource.assetResources(for: asset).first?.uniformTypeIdentifier ?? "jpg"
                            }
                            manager.performSave(data: data, path: asset.localIdentifier.replacingOccurrences(of: "/", with: "") + "." + format, urlType: .temporary)
                        }
                        DispatchQueue.main.async {
                            self?.selectedIs.removeFirst()
                            self?.saveToTemp(manager: manager, completion: completion)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.saving = false
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
                        print(Thread.isMainThread, " yhrftgbvcghfjg ")
                        completion(data as Data)
                    } else {
                        print(error, " tregfds ")
                        completion(nil)
                    }
                })
        }
    
    func fetchThumb(_ asset: PHAsset,
                    completion: @escaping(_ image: UIImage?) -> ()) {
        DispatchQueue(label: "thumb", qos: .userInitiated).async {
            let imageManager = PHCachingImageManager()
            let size: CGSize = .init(width: 60, height: 60)
            imageManager.requestImage(for: asset, targetSize: size,
                                      contentMode: .aspectFill,
                                      options: nil) { image, _ in
                let data = image?.jpegData(compressionQuality: 0.1)
                let image = UIImage(data: data ?? .init())
                DispatchQueue.main.async {
                    completion(image?.changeSize(newWidth: 20))
                }
            }
        }
    }
}
