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
    
    associatedtype Response: Codable
    
}
