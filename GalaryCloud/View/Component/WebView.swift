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
    let html:String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)

    }
}
