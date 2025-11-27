//
//  LoginRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct LoginRequest: Requestable, Codable {
    typealias Response = LoginResponse
    
    static var path: String { "user/login" }
    
    static var method: URLSession.Method { .get }
    
    let username: String
    let password: String
    let fastLogin: Int
}

struct LoginResponse: Codable {
    let success: Bool
    let user: String?
    let responseMessage: String?
    let code: Int?
}
