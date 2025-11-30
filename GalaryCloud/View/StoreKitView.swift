//
//  StoreKitView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import SwiftUI
import StoreKit

struct StoreKitView: View {
    
    @StateObject private var storeKitService: StoreKitPurchaseService = .init()
    
    var body: some View {
        TabView {
            ForEach(storeKitService.products, id: \.id) { product in
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.displayName)
                        Text(product.displayPrice)
                    }
                    Text(product.description)
                    Text("\(product.subscription?.subscriptionPeriod.value ?? 0)")
                    Button("Buy") {
                        
                    }
                }
            }
        }
        .tabViewStyle(.page)
        .background(content: {
            ClearBackgroundView()
        })
        .background(.primaryContainer)
    }
}
