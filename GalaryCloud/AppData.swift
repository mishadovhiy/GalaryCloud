//
//  AppData.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Combine
import Foundation

class AppData: ObservableObject {
    @Published var message: [MessageModel] = []
}
