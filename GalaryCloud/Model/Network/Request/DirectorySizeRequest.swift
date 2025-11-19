//
//  DirectorySizeRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 19.11.2025.
//

import Foundation

struct DirectorySizeRequest: Requestable {
    typealias Response = DirectorySizeResponse
    
    static var path: String { "file/directorySize" }
    
    static var method: URLSession.Method { .get }
    
    static var isCached: Bool { false }
    
    static var ignoreParameterKeys: Bool { false }
    
    let path: String
}
