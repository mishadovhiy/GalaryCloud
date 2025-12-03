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
                    LoaderView(isLoading: viewModel.isLoading)
                        .frame(maxWidth: 15)
                }
            }
        }
        .onAppear(perform: {
            viewModel.fetchImage(db: db, isSmallImageType: self.deleteImagePressed == nil)
        })
        .onDisappear {
            viewModel.viewDidDisapear()
        }
        .background(deleteImagePressed == nil ? .clear : .primaryContainer)
        .background {
            ClearBackgroundView()
        }
    }
    
    @ViewBuilder
    var dateView: some View {
        let date = DateComponents(string: viewModel.date)
        HStack(spacing: 20) {
            if deleteImagePressed != nil {
                VStack(alignment: .leading) {
                    Text(date.stringDate)
                        .font(deleteImagePressed == nil ? .footnote : .body)
                        .multilineTextAlignment(.leading)
                    Text(date.stringTime)
                        .font(.system(size: 9))
                        .opacity(0.6)
                        .multilineTextAlignment(.leading)
                }
                .frame(alignment: .leading)
                Spacer()
                buttons
                    .frame(maxHeight: 50)
            } else {
                Text("\(date.day ?? 0)")
                    .font(.system(size: 9))
            }
            
        }
        .padding(.horizontal, 10)
        .foregroundColor(.primaryText)
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        if self.deleteImagePressed == nil {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
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
