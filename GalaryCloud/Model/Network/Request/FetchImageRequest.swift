//
//  FetchImageRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct FetchImageRequest: Codable, Requestable {
    typealias Response = FetchFileResponse
    
    static var path: String { "file/fetchFile2" }
    
    static var method: URLSession.Method { .get }
    
    let username: String
    let filename: String
}
struct FetchFileResponse: Codable {
    let url: String
}
