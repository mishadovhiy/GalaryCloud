//
//  DeleteAccountRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 04.12.2025.
//

import Foundation

struct DeleteAccountRequest: Requestable {
    typealias Response = BaseResponse
    
    static var path: String { "file/deleteUser" }
    
    static var method: URLSession.Method { .post }
    
    let username: String
    
}
