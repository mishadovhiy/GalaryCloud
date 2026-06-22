//
//  AppDelegate.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 21.11.2025.
//

import SwiftUI
import Combine

class AppDelegate: NSObject, UIApplicationDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print(bytesSent / totalBytesExpectedToSend, " tgerfdwsa ")
    }

    @Published var notificationsToken: String = ""
    static var didReciveNotification:((_ userInfo: [AnyHashable : Any])->())?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BackgroundTaskService().configure()

        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        self.notificationsToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        #if !os(tvOS)
        AppDelegate.didReciveNotification?(notification.request.content.userInfo)
        #endif
        completionHandler([.banner, .sound])
    }
    
}
