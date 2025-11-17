//
//  Codable+Decodable.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

extension Decodable {
    init(_ data: Data?) throws {
        guard let data else {
            throw NSError(domain: "no data", code: -10)
        }
        do {
            let decoder = PropertyListDecoder()
            let decodedData = try decoder.decode(Self.self, from: data)
            self = decodedData
        } catch {
#if DEBUG
            print("error decoding data ", error)
#endif
            throw error
        }
    }
}

extension Encodable {
    func encode() throws -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
            return try encoder.encode(self)
        }
        catch {
#if DEBUG
            print("error encoding PropertyListEncoder, keep trying", error)
#endif
            return try JSONEncoder().encode(self)
        }
    }
    
    func dictionary() throws -> [String:Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json
        } catch {
            throw error
        }
    }
}
