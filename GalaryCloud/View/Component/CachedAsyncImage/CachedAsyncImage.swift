//
//  CachedAsyncImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI
import Combine

struct CachedAsyncImage: View {
    
    private let didDeleteImage: (()->())?
    @StateObject private var viewModel: CachedAsyncImageViewModel
    @EnvironmentObject private var db: DataBaseService

    init(presentationType: CachedAsyncImageViewModel.PresentationType, didDeleteImage: (() -> Void)? = nil) {
        self.didDeleteImage = didDeleteImage
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
        .modifier(AlertModifier(messages: $viewModel.messages))
        .onAppear(perform: {
            viewModel.fetchImage(db: db, isSmallImageType: self.didDeleteImage == nil)
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
                if didDeleteImage != nil {
                    Spacer()
                    buttons
                }

            }
        }
    }
    
    @ViewBuilder
    var buttons: some View {
        Button {
            viewModel.savePressed()
        } label: {
            Text("save")
        }
        Button {
            viewModel.deletePressed(didDelete: {
                self.didDeleteImage?()
            })
        } label: {
            Text("delete")
        }
    }
}
