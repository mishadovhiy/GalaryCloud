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
        WebView(html: privacyPolicyContent ?? "")
            .background(content: {
                ClearBackgroundView()
            })
            .background(SidebarView.Constants.background)
            .onAppear {
                Task {
                    let request = URLSession.shared.dataTask(with: .init(url: .init(string: urlType.url)!)) { data, _, _ in
                        let string = String(data: data ?? .init(), encoding: .utf8) ?? ""
                        let result = unparcePrivacyPolicy(string)
                        DispatchQueue.main.async {
                            privacyPolicyContent = result
                        }
                    }
                    request.resume()
                }
            }
    }
    
    func unparcePrivacyPolicy(_ response:String) -> String {
                        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        </head>
        <style>
        html, body{background: #0A0A0A;}
        h2{ font-size: 18px; color: white; }h1{font-size: 32px; color: white;}
        p, ul, li{font-size: 12px; color: white;}
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
