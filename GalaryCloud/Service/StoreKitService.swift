//
//  StoreKit.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import StoreKit
import Foundation
import Combine

class StoreKitService: NSObject, ObservableObject {
    @Published var activeTransactions: [Transaction] = []
    @Published var activeProducts: [Product] = [] {
        didSet {
            subscribtionChackedDate = .init()
        }
    }
    @Published var allProducts: [Product] = []
    var activeSubscription: Product? {
        activeProducts.sorted(by: {$0.price > $1.price}).first
    }
    var activeSubscriptionGB: Int {
        (activeSubscription?.description.numbers ?? 15)
    }
    
    private let productIDs: [String]
    
    init(needAllProducts: Bool = false, productIDs: [String] = []) {
        self.productIDs = productIDs
        super.init()
        if needAllProducts {
            Task {
                await self.fetchAllProducts()
            }
        } else {
            Task {
                await self.fetchActiveProducts()
            }
        }
    }
    
    func fetchAllProducts() async {
        self.allProducts = await fetchProducts()
        print(allProducts.count, " hftdgsfda ")
        await fetchActiveProducts(force: true)
    }
    
    func fetchProducts(ids: [String]? = nil) async -> [Product] {
        do {
            let products = try await Product.products(for: ids ?? productIDs)
            return products.sorted(by: { $0.price < $1.price })
        } catch {
            print("StoreKit error:", error)
            return []
        }
    }
    
    private var subscribtionChackedDate: Date?
    
    func fetchActiveProducts(force: Bool = false) async {
        print(Date(), " yhrtgrfsd")
        if !force,
           let subscribtionChackedDate,
           Calendar.current.isDateInToday(subscribtionChackedDate) {
            return
        }
        var transactions: [Transaction] = []
        for await result in Transaction.currentEntitlements {
            switch result {
            case .unverified(_, _):
                continue
            case .verified(let transaction):
                if transaction.productType == .autoRenewable {
                    transactions.append(transaction)
                }
            }
        }
        print(transactions, " hyrtgerfwedas ")
        await MainActor.run {
            self.activeTransactions = transactions
        }
        if transactions.isEmpty {
            print(Date(), " yhrtgrfsd")
            await MainActor.run {
                self.activeProducts = []
            }
        } else {
            let productIDs = transactions.compactMap { $0.productID }
            if productIDs.isEmpty {
                self.activeProducts = []
                return
            } else if !allProducts.isEmpty {
                let products = allProducts.filter({
                    productIDs.contains($0.id)
                })
                if products.count == productIDs.count {
                    await MainActor.run {
                        self.activeProducts = products
                    }
                    print(Date(), " yhrtgrfsdfs")
                    
                    return
                }
            }
            let products = await fetchProducts(ids: productIDs)
            await MainActor.run {
                print(Date(), " yhrtgrfsd")
                self.activeProducts = products
            }
        }
    }
    
    func buy(product: Product) async -> Result<Bool, Error> {
        do {
            let task = try await product.purchase()
            switch task {
            case .success(let verificationResult):
                print("successs")
                let transition = try verificationResult.payloadValue
                await transition.finish()
                return .success(true)
            case .userCancelled:
                print("usercanceled")
                
                return .failure(NSError(domain: "canceled", code: -1))
            case .pending:
                print("pending")
                return .success(false)
                
            @unknown default:
                print("default")
                return .failure(NSError(domain: "default unknown status", code: -2))
            }
        }
        catch {
            print(error)
            return .failure(error)
        }
    }
    
    func restorePurchases(db: DataBaseService) {
        Task {
            do {
                try await AppStore.sync()

                print("Restore completed")
                await MainActor.run {
                    db.messages.append(.init(title: "You all set"))
                }
            } catch {
                print("Restore failed: \(error)")
            }
        }
    }
    
    func requestAppStoreReview() {
        #if !os(tvOS)
#if !os(watchOS)
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        #endif
        #endif
    }
    
    func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                do {
                    switch result {
                    case .verified(let transaction):
                        await transaction.finish()
                    case .unverified(let transaction, let error):
                        print(error, #file, #line)
                    }
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
}
