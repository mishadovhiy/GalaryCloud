//
//  WasabiService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import Foundation
import AWSS3
import AWSCore

struct WasabiService {
    
    static func fetchURL(
        username: String,
        filename: String,
        completion: @escaping(_ url: URL?)->()) {
        let request = AWSS3GetPreSignedURLRequest()
        request.bucket = Keys.Service.Wasabi.buketName.rawValue
        request.key = "\(Keys.Service.Wasabi.fileDirectory.rawValue)/\(username)/\(filename)"
        request.httpMethod = .GET
        request.expires = Date(timeIntervalSinceNow: 3600)
        
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(request).continueWith { task in
            if let url = task.result as? URL {
                completion(url)
            } else {
                completion(nil)
            }
            return nil
        }
    }
}
