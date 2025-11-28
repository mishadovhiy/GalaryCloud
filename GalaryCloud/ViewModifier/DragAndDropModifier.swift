//
//  DragDelegate.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct DragAndDropModifier: ViewModifier {
    let disabled: Bool
    @Binding var lastDroppedID: String?

    let itemID: String
    let didDrop: ()->()
    
    func body(content: Content) -> some View {
        if !disabled {
            content
                .onDrag({
                    NSItemProvider(object: itemID as NSString)
                }, preview: {
                    EmptyView()
                })
                .onDrop(of: [.text], delegate: DragDelegate(targetItem: itemID, didDrag: {
                    if lastDroppedID != itemID {
                        lastDroppedID = itemID
                        didDrop()
                    }
                }))
        } else {
            content
        }
    }
}

fileprivate struct DragDelegate: DropDelegate {
    let targetItem: String?
    let didDrag: ()->()
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .copy)
    }

    func validateDrop(info: DropInfo) -> Bool {
        print(targetItem, " htgrefdsa ")
        didDrag()
        return true
    }
}

