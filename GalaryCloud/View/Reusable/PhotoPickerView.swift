//
//  PhotoPickerSysView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 04.12.2025.
//

import SwiftUI
import Combine
import Photos

struct PhotoPickerView: View, GalaryListProtocol {
    @State var isPresenting: Bool = true
    let completedSelection: ()->()
    private let fileManager: FileManagerService = .init()
    
    @StateObject private var manager: PHFetchManager = .init()
    @State private var assets: [Int: UIImage?] = [:]
    @State private var selectedOnScreenIndxs: [Int] = []
    @State private var lastDroppedID: String?
    @Environment(\.dismiss) private var dismiss
    @State var viewSize: CGSize = .zero
    var body: some View {
        if #available(iOS 16.4, *) {
            contentView
            #if !os(tvOS)
                .presentationBackgroundInteraction(.enabled)
            #endif
        } else {
            contentView
        }
    }
    
    var contentView: some View {
        ScrollView(content: {
            LazyVGrid(columns: (0..<gridCount).compactMap({ _ in
                    .init()
            })) {
                galaryView
            }
            .padding(.top, 64)
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: isPresenting ? .infinity : 0)
        })
        .overlay(content: {
            VStack {
                headerView
                Spacer()
            }
        })
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(.black)
        .clipped()
        .modifier(ViewSizeReaderModifier(viewSize: $viewSize))
        .presentationDetents([isPresenting ? .large : .height(50)])
        .colorScheme(.dark)
        .preferredColorScheme(.dark)
    }
    
    var headerView: some View {
        HStack(spacing: 15) {
            Spacer()
            if !manager.saving {
                Button("Deselect \(manager.selectedIs.count)") {
                    manager.selectedIs.removeAll()
                }
                .frame(maxHeight: .infinity)
                .modifier(LinkButtonModifier(type: .link))
                .background(content: {
                    BlurView()
                        .background(.black.opacity(0.15))
                })
                .cornerRadius(12)
                Button("Save \(manager.selectedIs.count)") {
                    hide()
                    if !manager.selectedIs.isEmpty {
                        manager.saving = true
                        manager.saveToTemp(manager: fileManager) {
                            completedSelection()
                            dismiss()
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .modifier(LinkButtonModifier(type: .link))
                .background(content: {
                    BlurView()
                        .background(.black.opacity(0.15))
                })
                .cornerRadius(12)
            } else {
                Text("Saving \(manager.selectedIs.count)")
                    .foregroundColor(.primaryText)
            }
            
        }
        .frame(maxHeight: !isPresenting ? (manager.selectedIs.isEmpty ? 0 : .infinity) : 36)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(content: {
            BlurView()
                .background(.black.opacity(0.75))
                .opacity(isPresenting ? 1 : 0)
                .animation(.smooth, value: isPresenting)
        })
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
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
        .cornerRadius(5)
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
extension PhotoPickerView {
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
    
    var gridCount: Int {
        let max:CGFloat = 90
        let count = Int(viewSize.width / max)
        if count <= 4 {
            return 4
        }
        return count
    }
}
