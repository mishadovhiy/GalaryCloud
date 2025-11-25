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
    
    let path: String
}
