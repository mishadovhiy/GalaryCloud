//
//  IconViewModel.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import Combine
import SwiftUI

class IconViewModel: ObservableObject {
    
    @Published var completed: Bool = false
    let canPressChanged: ((_ canPress: Bool)->())?
    
    init(canPressChanged: ((_: Bool) -> Void)?) {
        self.canPressChanged = canPressChanged
    }
    
    func toggleSuccessAnimation(completion: (()->())? = nil) {
        canPressChanged?(false)
        withAnimation(.bouncy(duration: 0.7)) {
            completed = true
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: { [weak self] in
            withAnimation(.smooth(duration: 0.3)) {
                self?.completed = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self?.canPressChanged?(true)
                completion?()
            })
        })
    }
}
