//
//  WebView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView()
        let data = try! Data(contentsOf: url)
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let webView = uiView as! WKWebView
    }
}
