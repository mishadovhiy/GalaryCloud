//
//  CreateUpdateAccountRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct CreateUpdateAccountRequest: Requestable, Codable {
    typealias Response = BaseResponse
    
    static var path: String { "user/create" }
    
    static var method: URLSession.Method { .get }
    
    var canUpdate: Int = 1
    let username: String
    let password: String
}
