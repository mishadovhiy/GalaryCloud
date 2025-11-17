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
        #warning("todo: move to services")
        private func safeFile(libraryURL: URL) -> URL? {
            let filename = libraryURL.lastPathComponent
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            
            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: libraryURL, to: tempURL)
                return tempURL
            } catch {
                return nil
            }
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            DispatchQueue.main.async {
                picker.dismiss(animated: true)
            }
            var selectedURLs: [URL] = []
            results.forEach { result in
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    if let url,
                       let newURL = self.safeFile(libraryURL: url)
                    {
                        selectedURLs.append(newURL)
                    }
                    if results.last == result {
                        DispatchQueue.main.async {
                            self.parent.imageSelected(selectedURLs)
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

