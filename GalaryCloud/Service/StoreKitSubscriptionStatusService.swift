//
//  StoreKitSubscriptionStatusService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import Foundation
import Combine
import StoreKit

class StoreKitSubscriptionStatusService: ObservableObject {
    func activeSubscriptionProductID() async -> String? {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .unverified(_, _):
                continue
            case .verified(let transaction):
                if transaction.productType == .autoRenewable {
                    return transaction.productID
                }
            }
        }
        return nil
    }
}
