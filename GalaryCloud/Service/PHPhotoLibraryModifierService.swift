//
//  PHPhotoLibraryModifierService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 26.11.2025.
//

import Foundation
import Photos

struct PHPhotoLibraryModifierService {
    func save(data: Data,
                     date: String,
                     completion: @escaping(_ success: Bool)->()) {
        PHPhotoLibrary.shared().performChanges({

                let request = PHAssetCreationRequest.forAsset()
            request.creationDate = .init(string: date)
            request.addResource(with: .photo, data: data, options: nil)
            }) { success, error in
                DispatchQueue.main.async {
                    completion(success)
                }
//                let title = success ? "Saved to Photos!" : "Error saving"
//                DispatchQueue.main.async {
//                    messages.append(.init(title: title))
//                }
            }
    }
}
