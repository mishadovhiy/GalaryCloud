//
//  URLSession.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

extension URLSession {
    
    func resumeTask<T: Requestable>(_ requestable: T) async -> Result<T.Response, Error> {
        do {
            let request = try URLRequest.init(requestable)
            let response = try await self.performTask(request: request)
            switch response {
            case .success(let data):
                if T.Response.self == Data.self {
                    return .success(data as! T.Response)
                }
                let result = try T.Response.init(data)
                return .success(result)
            case .failure(let error):
                print((error as NSError).domain)
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
        
    func performTask(request: URLRequest) async throws -> Result<Data, Error> {
        do {
            let (data, response) = try await self.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw NSError(domain: NSURLErrorDomain, code: URLError.badServerResponse.rawValue)
            }
            let error = try? JSONDecoder()
                .decode(ErrorResponse.self, from: data)
            if let error {
                throw NSError(domain: error.message, code: URLError.errorDomain.hashValue)
            }
            return .success(data)
        }
        catch {
            throw error
        }
    }
}

extension URLSession {
    enum Method: String {
        case post
        case get
    }
}
