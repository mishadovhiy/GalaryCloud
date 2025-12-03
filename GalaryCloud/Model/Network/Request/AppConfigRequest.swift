//
//  AppConfigRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 03.12.2025.
//

import Foundation

struct AppConfigRequest: Requestable {
    typealias Response = AppConfigResponse
    
    static var path: String { "generalParameters" }
    
    static var method: URLSession.Method { .getJson }
    
    
}
