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
        let urlString = Keys.serverURL.rawValue + requestableType.path + ".php"
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
        let type = type(of: requestable)
        switch type.method {
        case .get:
            guard let requestDictionary = try requestable.dictionary() else {
                throw NSError(domain: "Error encoding data", code: -3)
            }
            let requestString = requestDictionary
                .map({
                    return $0.key + "=" + "\($0.value)"
                })
                .joined(separator: "&")
            return "?" + requestString
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
            self.httpBody = try! requestable.encode()
        default: break
        }
    }
}


extension Date {
    var string: String {
        if #available(iOS 16.0, *) {
            self.ISO8601Format(.iso8601(timeZone: .current, includingFractionalSeconds: true, dateSeparator: .dash, dateTimeSeparator: .space, timeSeparator: .colon))
        } else {
            self.ISO8601Format()
        }
    }
    
    init(string: String) {
        let formatter = Date.formatter()
        if let date = formatter.date(from: string) {
            self = date

        } else {
            let formatter2 = Date.formatter(dateSeparetor: ":")
            if let date = formatter2.date(from: string) {
                self = date
            } else {
                print("errorconverting date ", string)
                let formatter3 = Date.formatter(dateSeparetor: ":", short: true)
                if let date = formatter3.date(from: string) ?? Date.formatter(dateSeparetor: "-", short: true).date(from: string) {
                    self = date
                } else {
                    self = .now
                }
            }
            
        }
    }
    
    fileprivate static func formatter(dateSeparetor: String = "-", short: Bool = false) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy\(dateSeparetor)MM\(dateSeparetor)dd" + (short ? "" : " HH:mm:ss")
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
