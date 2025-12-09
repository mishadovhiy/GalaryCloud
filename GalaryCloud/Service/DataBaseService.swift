//
//  AppData.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import Combine
import Foundation
import SwiftUI

class DataBaseService: ObservableObject {
    private let dbkey = "db8"
    #warning("todo: move to AppData")
    let imageCache = NSCache<NSString, UIImage>()
    @Published var checkIsUserLoggedIn: Bool = false
    @Published var messages: [MessageModel] = []
    @Published var storageUsed: Int = 0
    @Published var totalFileCount: Int = 0
    @Published var storeKitService: StoreKitService = .init(needAllProducts: false)
    // for updating height of sidebar
    @Published var isStoreKitPresenting: Bool = false
    @Published var forcePresentUpgradeToPro: Bool = false
    @Published var currentLoading: String?
    @Published var allLoaders: Set<String> = [] {
        didSet {
            if currentLoading == nil {
                currentLoading = Array(allLoaders).last
                #if DEBUG
                print(currentLoading, " currentLoadingItem ")
                #endif
            }
            #if DEBUG
            print(allLoaders.count, " leftItemsToLoad ")
            #endif
        }
    }
    
    @Published var db: DataBaseModel? {
        didSet {
            if db == nil {
                return
            }
            if Thread.isMainThread {
                Task {
                    try? UserDefaults.standard.setValue(db.encode() ?? .init(), forKey: dbkey)
                }
            } else {
                try? UserDefaults.standard.setValue(db.encode() ?? .init(), forKey: dbkey)
            }
        }
    }
    
    init () {
        let db = UserDefaults.standard.data(forKey: dbkey)
        do {
            self.db = try .init(db)
        } catch {
            self.db = .init()
        }
        imageCache.totalCostLimit =  512 * 1024 * 1024
        
        storeKitCancellable = storeKitService.objectWillChange.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
    
    private var storeKitCancellable: AnyCancellable?

}
