//
//  ErrorResponse.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct ErrorResponse: Codable {
    let message: String
    let code: Int?
    
    var errorCode: ErrorCode? {
        guard let code else {
            return nil
        }
        return .init(rawValue: code)
    }
    
    enum ErrorCode: Int {
        case Authorization_WrongPassword = 118244589
        case Authorization_UserNotFound = 118234589
        case Authorization_UserUpdated = 118236589
    }
}
