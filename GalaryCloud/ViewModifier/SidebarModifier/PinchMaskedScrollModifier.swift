//
//  PinchMaskedScrollModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import SwiftUI
import Combine

class PinchMaskedScrollModifierModel: ObservableObject {
    var viewWidth: CGFloat = 0

    @Published var dragPositionX: CGFloat = 0
    
    @Published var isScrollActive: Bool = false
    @Published var isOpened = false

    var lastPosition: CGFloat = 0
    var scrollingToOpen: Bool = false
    let maxPercent = 0.28
    var openPercent: CGFloat {
        maxPercent / 2
    }
    /// percent to opened position
    let closePercent = 0.74

    var validatedPosition: CGFloat {
        dragPositionX >= 0 ? dragPositionX : 0
    }
    
    var maxDragPercent: CGFloat {
        let value = dragPercent
        if value > 1 {
            return 1
        } else if value < 0 {
            return 0
        }
        return value
    }
    
    var dragPercent: CGFloat {
        let value = dragPositionX / (viewWidth * maxPercent)
        if value >= .zero {
            return value
        } else {
            return 0
        }
    }

    var toOpenScrollingPercent: CGFloat {
        !isOpened ? 1 - dragPercent : (!scrollingToOpen ? (1 - dragPercent) : 0)
    }

    var toCloseScrollingPercent: CGFloat {
        isOpened ? dragPercent : (scrollingToOpen ? dragPercent : 0)
    }

    var maxScrollX: CGFloat {
        viewWidth * maxPercent
    }

    var sideBarZindex: CGFloat {
        isOpened && !isScrollActive ? 9999 : 0
    }

    var validViewOffset: CGFloat {
        (viewWidth * 0.4) * dragPercent
    }

    private var declaringPosition: CGFloat {
        let newPosition: CGFloat
        let openPosition = (maxPercent * viewWidth)
        let multiplier = (isOpened ? (closePercent * maxPercent) : openPercent)
        let targetWidth = multiplier * viewWidth
        if isOpened {
            newPosition = dragPositionX < targetWidth ? .zero : openPosition
        } else {
            newPosition = dragPositionX > targetWidth ? openPosition : .zero
        }
        return newPosition
    }

    func scrollEnded() {
        let newPosition = declaringPosition
        DispatchQueue.main.async {
            let isOpened = newPosition >= self.openPercent
            withAnimation(.smooth(duration: 0.5)) { [weak self] in
                guard let self else { return }
                dragPositionX = newPosition
                lastPosition = newPosition
                if !isOpened {
                    self.isOpened = isOpened
                    self.isScrollActive = false

                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: { [weak self] in
                guard let self else { return }
                withAnimation(.smooth) {
                    self.isOpened = isOpened
                }
                self.isScrollActive = false

            })
        }
    }

    func scrollStarted() {
        if isScrollActive {
            let multiplier = (isOpened ? (closePercent * maxPercent) : openPercent)
            let targetWidth = multiplier * viewWidth

            if isOpened {
                self.scrollingToOpen = !(dragPositionX < targetWidth)
            } else {
                self.scrollingToOpen = dragPositionX > targetWidth
            }
            return
        }
        isScrollActive = true
        isOpened = lastPosition >= openPercent
    }

    func toggleMenuPressed() {
        let newPosition: CGFloat = isOpened ? .zero : (maxPercent * viewWidth)
        let isOpened = isOpened
        withAnimation(.bouncy(duration: 0.46)) {
            self.lastPosition = newPosition
            self.dragPositionX = newPosition
            if isOpened {
                self.isOpened.toggle()
                self.isScrollActive = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(460), execute: {
            if !isOpened {
                withAnimation {
                    self.isOpened.toggle()
                    self.isScrollActive = false
                }
            }
        })
    }
}
