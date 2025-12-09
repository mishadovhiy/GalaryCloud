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
    @Binding var isPresenting: Bool
    let completedSelection: ()->()
    private let fileManager: FileManagerService = .init()
    
    @StateObject private var manager: PHFetchManager = .init()
    @State private var assets: [Int: UIImage?] = [:]
    @State private var selectedOnScreenIndxs: [Int] = []
    @State private var safeArea: EdgeInsets = .init()
    @State private var lastDroppedID: String?
    
    var body: some View {
        VStack(content: {
            Spacer().frame(height: safeArea.top + 50)
            Spacer()
            contentView
                .frame(maxHeight: isPresenting ? .infinity : manager.selectedIs.isEmpty ? 0 : 100)
        })
        .ignoresSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .animation(.bouncy, value: isPresenting)
        .modifier(ViewSizeReaderModifier(safeArea: $safeArea))
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            headerView
            ScrollView(content: {
                LazyVGrid(columns: (0..<4).compactMap({ _ in
                        .init()
                })) {
                    galaryView
                }
            })
            .ignoresSafeArea(.all)

            .frame(maxWidth: .infinity, maxHeight: isPresenting ? .infinity : 0)
            .background(.red)
            .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(.black)
        .cornerRadius(20)
        .shadow(radius: 11)
        .padding(.horizontal, 10)
        .padding(.top, 20)
    }
    
    var headerView: some View {
        HStack {
            if isPresenting {
                Button {
                    hide()
                } label: {
                    MenuIconShape(type: .close)
                }
                .frame(maxHeight: .infinity)
                .modifier(LinkButtonModifier(type: .link))
                .padding(.horizontal, 15)
            }
            
            Spacer()
            if !manager.saving {
                Button("Deselect \(manager.selectedIs.count)") {
                    manager.selectedIs.removeAll()
                }
                .frame(maxHeight: .infinity)
                .modifier(LinkButtonModifier(type: .link))
                .padding(.horizontal, 15)
                Button("save \(manager.selectedIs.count)") {
                    hide()
                    if !manager.selectedIs.isEmpty {
                        manager.saving = true
                        manager.saveToTemp(manager: fileManager) {
                            completedSelection()
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .modifier(LinkButtonModifier(type: .link))
                .padding(.horizontal, 15)
            } else {
                Text("Saving \(manager.selectedIs.count)")
                    .foregroundColor(.primaryText)
            }
            
        }
        .frame(maxHeight: !isPresenting ? .infinity : 44)
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
                .modifier(DragAndDropModifier(disabled: false, itemID: "\(i)", didDrop: {
                    print("didDropdidDrop")
                    manager.selectI(i, onScroll: true)
                }, didEndDragging: {
                    print("didEndDragging")
                    manager.lastSelectedID = nil
                }))
                .onTapGesture {
                    manager.selectI(i)
                }
                .onAppear(perform: {
                    imageAppeared(i)
                })
                .onDisappear {
                    imageDisapeared(i)
                }
        }
    }
}

fileprivate
extension PhotoPickerSysView {
    func imageAppeared(_ i: Int) {
        if assets[i] == nil,
           let asset = manager.assets?.object(at: i)
        {
            manager.fetchThumb(asset) { image in
                self.assets.updateValue(image, forKey: i)
            }
        }
    }
    
    func imageDisapeared(_ i: Int) {
        selectedOnScreenIndxs.removeAll(where: {
            $0 == i
        })
        assets.removeValue(forKey: i)
    }
    
    func hide() {
        withAnimation {
            isPresenting = false
        }
    }
}
