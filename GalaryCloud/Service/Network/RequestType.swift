//
//  RequestType.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

enum RequestType {
    
    case login(LoginRequest)
    case createUpdateAccount(CreateUpdateAccountRequest)
    case createFile(CreateFileRequest)
    case fetchFiles(FetchFilesRequest)
    
    var request: any Requestable {
        switch self {
        case .login(let request):
            request
        case .createUpdateAccount(let request):
            request
        case .createFile(let request):
            request
        case .fetchFiles(let request):
            request
        }
    }
}
