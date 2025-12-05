//
//  WasabiConfig.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import AWSS3
import AWSCore
import BackgroundTasks

struct WasabiConfig: AppServiceConfig {
    func configure() {
        let credentials = AWSStaticCredentialsProvider(
            accessKey: Keys.Service.Wasabi.token.rawValue,
            secretKey: Keys.Service.Wasabi.secretKey.rawValue
        )

        let endpoint = AWSEndpoint(
            region: .APNortheast2,
            service: .S3,
            url: URL(string: Keys.Service.Wasabi.regionURL.rawValue)!
        )

        let config = AWSServiceConfiguration(
            region: .USEast1,
            endpoint: endpoint,
            credentialsProvider: credentials
        )

        AWSServiceManager.default().defaultServiceConfiguration = config
    }
    
}
