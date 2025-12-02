//
//  CodeRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import Foundation

struct CodeRequest: Requestable {
    typealias Response = BaseResponse
    
    static var path: String { "user/sendCode" }
    
    static var method: URLSession.Method { .get }
    
    let emailTo: String
    //code generated on the client
    let resetCode: String
    
}
