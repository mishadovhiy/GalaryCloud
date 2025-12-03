//
//  NoDataView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 03.12.2025.
//

import SwiftUI

struct NoDataView: View {
    
    let text: String
    let image: ImageResource?
    
    init(text: String, image: ImageResource? = nil) {
        self.text = text
        self.image = image
    }
    
    var body: some View {
        VStack {
            if let image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150)
            }
            
            Text(text)
                .font(.headline)
                .foregroundColor(.primaryText)
                .padding(.horizontal, 20)
        }
    }
}

