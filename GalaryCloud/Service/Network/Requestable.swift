//
//  Requestable.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

protocol Requestable: Codable {
    
    static var path: String { get }
    
    static var method: URLSession.Method { get }
    
    static var isCached: Bool { get }
    
    /// only values would be used in the request
    static var ignoreParameterKeys: Bool { get }
    
    associatedtype Response: Codable
    
}
