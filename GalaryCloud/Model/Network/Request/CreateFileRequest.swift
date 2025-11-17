//
//  CreateFileRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct CreateFileRequest: Requestable, Codable {
    typealias Response = BaseResponse
    
    static var path: String { "file/create" }
    
    static var method: URLSession.Method { .post }
    
    static var ignoreParameterKeys: Bool { false }
    
    static var isCached: Bool { false }
    
    let username: String
    let originalURL: [Image]
    
    struct Image: Codable {
        let url: String
        let date: String
        let data: String
    }
}
