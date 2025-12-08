//
//  WebView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 27.11.2025.
//

import SwiftUI
import UIKit
#if !os(tvOS)
import WebKit
#endif

struct WebView: UIViewRepresentable {
    let html:String
    
    func makeUIView(context: Context) -> UIView {
#if os(tvOS)
        return .init()
#else
        let webView = WKWebView()
        webView.backgroundColor = .clear
        return webView
#endif
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
#if !os(tvOS)
        if let view = uiView as? WKWebView {
            view.loadHTMLString(html, baseURL: nil)
        }
#endif
    }
}
