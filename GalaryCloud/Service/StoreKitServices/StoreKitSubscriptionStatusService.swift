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
    private var lastCheckedDate: Date?
    //returns gb limits
    //fetch product by id to get localized description
    //if lastCheckedDate difference >= 1 hour
    
    
    
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
    
    //when availible gb <= occupied gb:
    //diable upload button ask user to select items that he doesn't need
}
