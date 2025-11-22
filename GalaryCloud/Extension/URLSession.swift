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
            if let cached = cachedIfCan(requestable, request: request) {
                return .success(cached as! T.Response)
            }
            let response = try await self.performTask(request: request)
            switch response {
            case .success(let data):
                cacheIfCan(response: data, requestable, request: request)
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

fileprivate extension URLSession {
    #warning("PHP cache not working: after fixing PHP, remove below")
    func cachedIfCan<T: Requestable>(_ requestable: T, request: URLRequest) -> Data? {
        let requestableType = type(of: requestable)
        if requestableType.isCached,
           let url = request.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
            let file = FileManager.default.load(path: url) {
            if T.Response.self == Data.self {
                return file
            }
        }
        return nil
    }
    
    func cacheIfCan<T: Requestable>(response: Data, _ requestable: T, request: URLRequest) {
        let requestableType = type(of: requestable)

        if requestableType.isCached {
            let _ = FileManager.default.save(data: response, path: request.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")
        }
    }
}


extension URLSession {
    enum Method: String {
        case post
        case get
    }
}
