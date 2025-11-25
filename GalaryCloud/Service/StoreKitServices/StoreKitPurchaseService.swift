//
//  StoreKit.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import StoreKit
import Foundation
import Combine

class StoreKitPurchaseService: NSObject, ObservableObject {
    @Published var products: [Product] = []
#warning("todo: buy pressed")

#warning("todo: load on app launch")
    private let productIDs: [String] = [
        "base",
        "average",
        "advanced",
        "pro",
        "vip"
    ]
    
    override init() {
        super.init()
        Task {
            await self.loadSubscriptions()
        }
    }
    
    func loadSubscriptions() async {
        do {
            
            let products = try await Product.products(for: productIDs)
            await MainActor.run {
                self.products = products.sorted(by: {$0.price >= $1.price})
            }
        } catch {
            print("StoreKit error:", error)
        }
    }

}
