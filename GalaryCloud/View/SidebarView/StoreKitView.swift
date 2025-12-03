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
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.displayName)
                            .font(.title)
                            .multilineTextAlignment(.leading)
                        Text("$" + "\(product.price)")
                            .font(.footnote)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.leading)
                    }
                    Text(product.description)
                        
                    HStack {
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
                        .frame(alignment: .trailing)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .modifier(LoadingButtonModifier(isLoading: false, type: .small))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(maxWidth: 230, alignment: .leading)
                .padding(.top, -40)

            }
        }
        .foregroundColor(.primaryText)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(content: {
            ClearBackgroundView()
        })
        .background(.primaryContainer)
    }
}
