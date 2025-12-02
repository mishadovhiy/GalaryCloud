//
//  PrivacyView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @State var privacyPolicyContent: String?
    
    var body: some View {
        WebView(html: privacyPolicyContent ?? "")
            .background(content: {
                ClearBackgroundView()
            })
            .background(SidebarView.Constants.background)
            .onAppear {
                Task {
                    let request = URLSession.shared.dataTask(with: .init(url: .init(string: Keys.privacyURL.rawValue)!)) { data, _, _ in
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
        html, body{background: #886DC7;}
        h2{ font-size: 18px; color: white; }h1{font-size: 32px; color: white;}
        p{font-size: 12px; color: white;}
        h1, h2, p{margin-left:10px;margin-right:10px;}
        </style>
        <body>
        """ + (response.extractSubstring(key: "!--Privacy--", key2: "!--/Privacy--") ?? "") + """
            </body>
            </html>
            """
    }
}

#Preview {
    PrivacyPolicyView()
}
