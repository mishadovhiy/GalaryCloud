//
//  BackgroundTaskService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 04.12.2025.
//

import Foundation
import Combine
#if !os(watchOS)
import BackgroundTasks
#endif
import UIKit

class BackgroundTaskService: ObservableObject {
    @Published var currentURL: URL?
#if !os(watchOS)
    func configure() {
        print("cofigure background task")
        let register = BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.myTask", using: .global()) { task in
//            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }
        print(register, " bujbjb ")
    }
    
    func scheduleTask(time: TimeInterval = 1) {
        let request = BGProcessingTaskRequest(identifier: "com.example.myTask")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: time)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("refqw")
        } catch {
            print("Could not schedule: \(error)")
        }
        
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            print("pending:", requests.map { $0.identifier })
            
        }
//        let id = UIBackgroundTaskIdentifier.invalid
//        UIApplication.shared.beginBackgroundTask(withName: "com.example.myTask") {
//            Task {
////                await self.upload {
//                    UIApplication.shared.endBackgroundTask(id)
////                }
//            }
//            
//        }
    }

    let fileManager = FileManagerService()
    
    func handleBackgroundTask(task: BGProcessingTask) {
        task.expirationHandler = {
            // clean up if task is killed by system
            print("expirationHandlerexpirationHandler")
        }
        print("startinggrr")

//        Task {
//            await self.upload {
//                DispatchQueue.main.async {
//                    self.currentURL = nil
//                }
//                task.setTaskCompleted(success: true)
//            }
//        }
    }
    
    func upload(completion: @escaping()->()) async {
        guard let first = fileManager.loadFiles(.temporary).first else {
            print("no filess")
            completion()
            return
        }
        print("uploaduploadupload", first.path())

        if UIApplication.shared.applicationState == .active {
            print(" activrefwe")
            DispatchQueue.main.async {
                self.currentURL = first
            }
        }
        await performUpload(first)
        fileManager.performDelete(path: first.path(), urlType: .temporary)
        return await upload(completion: completion)
    }
        
    private func performUpload(_ url: URL) async {
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        let date = data.imageDate ?? Date().string
        let stringData = data.base64EncodedString()
        let response = await URLSession.shared.resumeTask(CreateFileRequest(username: KeychainService.username, originalURL: [
            .init(url: url.lastPathComponent, date: date, data: stringData)
        ]))
        try? print(response.get().success, " trgertert ", url.absoluteString)
        return
        
    }
    #endif
}
