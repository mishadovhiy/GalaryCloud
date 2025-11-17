//
//  URLRequest.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

extension URLRequest {
    
    init(_ requestable: any Requestable) throws {
        let requestableType = type(of: requestable)
        let urlString = Keys.serverURL.rawValue + requestableType.path
        do {
            let suffix = try URLRequest.urlSuffix(requestable)
            
            guard let url = URL(string: urlString + suffix) else {
                throw NSError(domain: "Error creating url", code: URLError.badURL.rawValue)
            }
            self.init(url: url)
            try self.prepareRequest(requestable: requestable)
        }
        catch {
            throw error
        }
    }
    
    fileprivate static func urlSuffix(_ requestable: any Requestable) throws -> String {
        switch type(of: requestable).method {
        case .get:
            guard let requestDictionary = try requestable.dictionary() else {
                throw NSError(domain: "Error encoding data", code: -3)
            }
            let requestString = requestDictionary
                .map({$0.key + "=" + "\($0.value)"})
                .joined(separator: "&")
            return "/" + requestString
        default:
            return ""
        }
    }
    
    fileprivate mutating func prepareRequest(requestable: any Requestable) throws {
        let type = type(of: requestable)
        switch type.method {
        case .post:
            self.httpMethod = "POST"
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            self.httpBody = try requestable.encode()
        default: break
        }
    }
}
