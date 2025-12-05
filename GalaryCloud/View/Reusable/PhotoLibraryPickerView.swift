//
//  PhotoLibraryPickerView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import UIKit
import SwiftUI
import PhotosUI

struct PhotoLibraryPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    var imageSelected: (_ newImage: [URL]) -> ()
    
    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

        private let filemamager = FileManagerService()
        
        func type(result: PHPickerResult) -> String {
            let provider = result.itemProvider
            var types: [UTType] = [.image, .png, .jpeg, .heic, .heic, .heif, .aiff, .livePhoto, .ico, .icns, .tiff, .svg]
            if #available(iOS 18.0, *) {
                types.append(.heics)
            }
            if #available(iOS 18.2, *) {
                types.append(.jpegxl)
            }
            return types.first(where: {
                provider.hasItemConformingToTypeIdentifier($0.identifier)
            })?.identifier ?? UTType.image.identifier
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var selectedURLs: [URL] = []
            print(results.count, " thrgefdsca ")
            results.forEach { result in
                autoreleasepool {
                    let type = self.type(result: result)
                    print(result.assetIdentifier, " yh5gterf ", type)
                    
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: type) { url, error in
                        if let url,
                           let newURL = self.filemamager.copyFile(from: url)
                        {
                            selectedURLs.append(newURL)
                            
                        }
                        if url == nil {
                            print("error loading url rtevrfw")
                        }
                        if results.last == result {
                            DispatchQueue.main.async {
                                self.parent.imageSelected(selectedURLs)
                                picker.dismiss(animated: true)
                            }
                        }
                        if let error {
                            print(error, " rgefdws")
                        }
                        
                    }
                }
            }
        }
        
        var parent: PhotoLibraryPickerView
        init(parent: PhotoLibraryPickerView) { self.parent = parent }
        
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

