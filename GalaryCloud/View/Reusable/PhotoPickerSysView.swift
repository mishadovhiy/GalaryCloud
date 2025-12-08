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
    
    @StateObject private var manager: PHFetchManager = .init()
    @State private var assets: [Int: UIImage?] = [:]
    @State private var selectedOnScreenIndxs: [Int] = []
    @State var safeArea: EdgeInsets = .init()
    @State var lastDroppedID: String?
    
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
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 15)
            Spacer()
            Button("deselect \(manager.selectedIDs.count)") {
                manager.selectedIDs.removeAll()
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 15)
            Button("save \(manager.selectedIDs.count)") {
                manager.saveToTemp(manager: fileManager) {
                    completedSelection()
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 15)
        }
        .frame(height: 44)
        .padding(.horizontal, 10)
        .padding(.top, 50)
        .background(.orange)
    }
    
    func galaryImage(_ i: Int) -> some View {
        GeometryReader(content: { proxy in
            VStack {
                if let image = self.assets[i],
                   let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    LoaderView(isLoading: true)
                        .frame(width: 30, height: 30)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        })
        .aspectRatio(1, contentMode: .fill)
        .clipped()
        .overlay(content: {
            if manager.selectedIs.contains(i) {
                selectionIndicator
            }
        })
    }
    
    var selectionIndicator: some View {
        Color.red.opacity(0.3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
            .disabled(true)
    }
    
    @ViewBuilder
    var galaryView: some View {
        ForEach(0..<(manager.assets?.count ?? 0), id: \.self) { i in
            galaryImage(i)
                .modifier(DragAndDropModifier(disabled: false, lastDroppedID: $lastDroppedID, itemID: "\(i)", didDrop: {
                    manager.selectI(i, onScroll: true)
//                    select(i)
                }, didEndDragging: {
                    manager.lastSelectedID = nil
                }))
                .onTapGesture {
                    manager.selectI(i)
//                    select(i)
                }
                .onAppear(perform: {
                    imageAppeared(i)
                })
                .onDisappear {
                    imageDisapeared(i)
                }
                .onChange(of: manager.selectedIDs) { newValue in
                    self.selectedListChanged(appearedAssetIndx: i)
                }
        }
    }
}

fileprivate
extension PhotoPickerSysView {
    func select(_ i: Int) {
        if let asset = manager.assets?.object(at: i)
        {
            manager.select(asset: asset)
        }
    }
    
    func imageAppeared(_ i: Int) {
        if assets[i] == nil,
           let asset = manager.assets?.object(at: i)
        {
            manager.fetchThumb(asset) { image in
                self.assets.updateValue(image, forKey: i)
            }
            if manager.selectedIDs.contains(asset) {
                selectedOnScreenIndxs.append(i)
            }
            
        }
    }
    
    func imageDisapeared(_ i: Int) {
        selectedOnScreenIndxs.removeAll(where: {
            $0 == i
        })
        assets.removeValue(forKey: i)
    }
    
    func selectedListChanged(appearedAssetIndx i: Int) {
        if let asset = manager.assets?.object(at: i)
        {
            if manager.selectedIDs.contains(asset) {
                selectedOnScreenIndxs.append(i)
            } else {
                selectedOnScreenIndxs.removeAll(where: {
                    $0 == i
                })
            }
        }
    }
}
