//
//  StoreKit.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import StoreKit
import Foundation
import Combine

class StoreKitPurchaseService: ObservableObject {
    @Published var products: [Product] = []
    private let productIDs: [String] = [
        "base",
        "average",
        "advanced",
        "pro",
        "vip"
    ]
    
    init() {
        Task {
            await self.loadSubscriptions()
        }
    }
    
    func loadSubscriptions() async {
        do {
            
            let products = try await Product.products(for: productIDs)
            await MainActor.run {
                self.products = products
            }
        } catch {
            print("StoreKit error:", error)
        }
    }

}
