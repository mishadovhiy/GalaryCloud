//
//  NotificationCenterConfig.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 03.12.2025.
//

import Foundation
import UserNotifications
import UIKit

struct NotificationCenterConfig: AppServiceConfig {
    
    func configure() {
#if !os(watchOS)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        UNUserNotificationCenter.current().delegate = appDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied: \(String(describing: error))")
            }
        }
        #endif
    }
}
