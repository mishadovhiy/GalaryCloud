//
//  DeleteFileRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 22.11.2025.
//

import Foundation

struct DeleteFileRequest: Requestable {
    typealias Response = BaseResponse
    
    static var path: String { "file/delete" }
    
    static var method: URLSession.Method { .post }
    
    static var isCached: Bool { false }
    
    static var ignoreParameterKeys: Bool { false }
    
    let username: String
    let filename: String
}
