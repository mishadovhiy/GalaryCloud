//
//  RootAlertModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 28.11.2025.
//

import SwiftUI
import UIKit

struct RootAlertConfigModifier: ViewModifier {
    
    @EnvironmentObject private var db: DataBaseService
    
    func body(content: Content) -> some View {
        content
            .onChange(of: db.messages.last) { newValue in
                
                print("erfwedas")
                if newValue == nil {
                    return
                }
                self.presentAlert()
            }
    }
    
    private func presentAlert() {
        guard let lastMessage = db.messages.last else {
            return
        }
        let topVC = UIApplication.shared.activeWindow?.rootViewController?.topViewController
        if topVC is UIAlertController {
            return
        }
        let alert = UIAlertController(title: "Error", message: lastMessage.title, preferredStyle: .alert)
        addActions(alert)
        
        topVC?.present(alert, animated: true, completion: nil)
    }
    
    
    private func addActions(_ alert: UIAlertController) {
        guard let lastMessage = db.messages.last else {
            return
        }
        if lastMessage.buttons.isEmpty {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                alert.dismiss(animated: true) {
                    if db.messages.last != nil {
                        db.messages.removeLast()
                    }
                }
            }))
        } else {
            lastMessage.buttons.forEach { button in
                alert.addAction(UIAlertAction(title: button.title, style: .default, handler: { _ in
                    button.didPress?()
                    alert.dismiss(animated: true) {
                        if db.messages.last != nil {
                            db.messages.removeLast()
                        }
                    }
                }))
            }
        }
    }

}
