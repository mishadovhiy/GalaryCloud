//
//  NSError.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 03.12.2025.
//

import Foundation

extension NSError {
    var unparcedDescription: String {
        domain + " (\(code))"
    }
}

extension Error {
    var unparcedDescription: String? {
        let error = self as NSError
        return error.domain + " (\(error.code))"
    }
}
