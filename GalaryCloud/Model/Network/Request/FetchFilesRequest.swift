//
//  FetchFilesRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct FetchFilesRequest: Requestable, Codable {
    static var path: String { "file/fetch" }
    
    static var method: URLSession.Method { .get }
    
    typealias Response = FetchFilesResponse
}
