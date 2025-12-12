//
//  PrivacyView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import SwiftUI

// presents specific block of html page
struct HTMLBlockPresenterView: View {
    @State var privacyPolicyContent: String?
    let urlType: URLType
    
    var body: some View {
        #if !os(watchOS) && !os(tvOS)
        WebView(html: privacyPolicyContent ?? "")
            .background(content: {
                ClearBackgroundView()
            })
            .background(SidebarView.Constants.background)
            .onAppear {
                viewAppeared()
            }
            .ignoresSafeArea(.all)
        #else
        ScrollView(content: {
            VStack {
                Text(privacyPolicyContent ?? "loading")
                    .focusable(true)
#if os(tvOS)
                Button("") {
                    
                }
                .focusable(true)
                .opacity(0.01)
                #endif
            }
        })
            .onAppear {
                viewAppeared()
            }
        #endif
    }
    
    func viewAppeared() {
        Task {
            let request = URLSession.shared.dataTask(with: .init(url: .init(string: urlType.url)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)) { data, _, _ in
                let string = String(data: data ?? .init(), encoding: .utf8) ?? ""
                let result = unparcePrivacyPolicy(string)
                DispatchQueue.main.async {
                    #if os(watchOS) || os(tvOS)
                    let keys = ["h1", "h2", "h3", "ul", "li", "p", "strong", "div"]
                    var string = string
                    keys.forEach {
                        string = string.replacingOccurrences(of: "<" + $0 + ">", with: "")
                            .replacingOccurrences(of: "</" + $0 + ">", with: "")
                    }
                    privacyPolicyContent = string
                        .extractSubstring(key: "main", key2: "/main") ?? string
                    #else
                    privacyPolicyContent = result
                    #endif
                }
            }
            request.resume()
        }
    }
    
    func unparcePrivacyPolicy(_ response:String) -> String {
                        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,500&display=swap" rel="stylesheet">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <style>
        @font-face{font-family:'Open Sans', sans-serif;font-display:swap;}
        html, body{background: #0A0A0A; margin-top:-20px; }
        h2{ font-size: 14px; color: white; }h1{font-size: 18; color: white;}
        p, ul, li{font-size: 10px; color: white;}
        h1, h2, p{margin-left:10px;margin-right:10px;}
        </style>
        <body>
        """
        //+ (response.extractSubstring(key: "!--\(urlType.tag)--", key2: "!--/\(urlType.tag)--") ?? "")
        + response
        + """
            
            </body>
            </html>
            """
    }
}

extension HTMLBlockPresenterView {
    enum URLType {
        case privacyPolicy
        case termsOfUse
        case custom(_ url: String, _ keys: String)
        
        var url: String {
            switch self {
            case .privacyPolicy:
                Keys.privacyURL.rawValue
            case .termsOfUse:
                Keys.termsURL.rawValue
            case .custom(let url, _):
                url
            }
        }
        
        var tag: String {
            switch self {
            case .privacyPolicy:
                    "Privacy"
            case .termsOfUse:
                    "TermsOfUse"
            case .custom(_, let keys):
                keys
            }
        }
    }

}
