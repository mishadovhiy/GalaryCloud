//
//  FetchImageRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct FetchImageRequest: Codable, Requestable {
    typealias Response = Data
    
    static var path: String { "file/uploads" }
    
    static var method: URLSession.Method { .get }
    
    #warning("refactor: use optional codable structure indeed ignoreParameterKeys, isCached")
    static var ignoreParameterKeys: Bool { true }
    static var isCached: Bool { true }
    
    let urlPathSuffix: String
}
