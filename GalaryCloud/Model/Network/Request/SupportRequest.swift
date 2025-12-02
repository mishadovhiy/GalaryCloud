//
//  SupportRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import Foundation

struct SupportRequest: Requestable {
    typealias Response = BaseResponse
    
    static var path: String { "sendEmail" }
    
    static var method: URLSession.Method { .get }
    
    var title: String
    var head: String
    var body: String
    
    init(title: String, head: String, body: String) {
        self.title = title
        self.head = head
        self.body = body
    }
}
