//
//  ShareView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import Foundation
import UIKit
import SwiftUI

struct ShareView: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
