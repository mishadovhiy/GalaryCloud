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
        .background(.primaryContainer)
        .background {
            ClearBackgroundView()
        }
    }
    
    var dateView: some View {
        HStack(spacing: 20) {
            Text(viewModel.date)
                .font(deleteImagePressed == nil ? .footnote : .body)
            Spacer()
            if deleteImagePressed != nil {
                buttons
                    .frame(maxHeight: 50)
            }
        }
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        if self.deleteImagePressed == nil {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .overlay {
                    VStack {
                        Spacer()
                        dateView
                    }
                }
        } else {
            VStack {
                dateView
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var buttons: some View {
        Button(action: {
            viewModel.performSaveImage(db)
        }, label: {
            SaveIconView(isLoading: viewModel.saveAnimating)
            .padding(.horizontal, 1)
            .padding(.top, -5)
            .padding(.bottom, -5)
            .scaleEffect(0.8)
            .opacity(viewModel.isLoading ? 0.5 : 1)
        })
        .modifier(CircularButtonModifier(isAspectRatio: true))
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 50)
        .disabled(viewModel.isLoading)
        
        
        Button {
            deleteImagePressed?()
        } label: {
            TrashIconView(isLoading: viewModel.deleteAnimating)
            .scaleEffect(1.15)
        }
        .modifier(CircularButtonModifier(isAspectRatio: true))
        .frame(maxWidth: 50)
        .aspectRatio(1, contentMode: .fit)
        
    }
}
