//
//  FetchFilesResponse.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct FetchFilesResponse: Codable {
    let totalRecords: Int
    let results: [File]
    
    struct File: Codable, Hashable {
        let originalURL: String
        let date: String
    }
}
