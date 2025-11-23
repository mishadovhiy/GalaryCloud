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
    }
}
