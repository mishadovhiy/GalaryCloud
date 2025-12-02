//
//  StoreKitView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import SwiftUI
import StoreKit

struct StoreKitView: View {
    
    @StateObject private var storeKitService: StoreKitService = .init(needAllProducts: true)
    @EnvironmentObject private var db: DataBaseService
    
    var body: some View {
        TabView {
            ForEach(storeKitService.allProducts, id: \.id) { product in
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.displayName)
                        Text(product.displayPrice)
                    }
                    Text(product.description)
                    Button("Buy") {
                        Task {
                            do {
                                let request = await storeKitService.buy(product: product)
                                switch request {
                                case .success(let success):
                                    print(success, " grvefcds")
                                    if success {
                                        Task {
                                            await db.storeKitService.fetchActiveProducts(force: true)
                                        }
                                    }
                                case .failure(let failure):
                                    print(failure.localizedDescription, " grterfwdesa ")
                                }
                            }
                        }
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
