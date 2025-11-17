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
    
    static var method: URLSession.Method { .getNotDecodedRequestKeys }
    
    let urlPathSuffix: String
}
