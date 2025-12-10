//
//  ShareView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import Foundation
import UIKit
import SwiftUI
#if !os(watchOS)
struct ShareView: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIViewController {
        #if os(tvOS)
        return .init()
        #else
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
        #endif
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif
