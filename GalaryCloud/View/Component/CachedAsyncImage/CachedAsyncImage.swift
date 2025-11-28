//
//  CachedAsyncImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI
import Combine

struct CachedAsyncImage: View {
    
    private let deleteImagePressed: (()->())?
    @StateObject private var viewModel: CachedAsyncImageViewModel
    @EnvironmentObject private var db: DataBaseService

    init(presentationType: CachedAsyncImageViewModel.PresentationType, deleteImagePressed: (() -> Void)? = nil) {
        self.deleteImagePressed = deleteImagePressed
        self._viewModel = StateObject(wrappedValue: .init(presentationType: presentationType))
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                imageView(image)
            }
            if viewModel.isLoading {
                VStack {
                    ProgressView().progressViewStyle(.circular)
                    if viewModel.image == nil {
                        Text(viewModel.date)
                    }
                    
                }
            }
        }
        .onAppear(perform: {
            viewModel.fetchImage(db: db, isSmallImageType: self.deleteImagePressed == nil)
        })
        .onDisappear {
            viewModel.viewDidDisapear()
        }
    }
    
    func imageView(_ image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            Spacer()
            HStack {
                Text(viewModel.date)
                if deleteImagePressed != nil {
                    Spacer()
                    buttons
                }

            }
        }
    }
    
    @ViewBuilder
    var buttons: some View {
        Button {
            viewModel.performSaveImage(db)
        } label: {
            Text("save")
        }
        .disabled(viewModel.isLoading)
        Button {
            deleteImagePressed?()
        } label: {
            Text("delete")
        }
    }
}
