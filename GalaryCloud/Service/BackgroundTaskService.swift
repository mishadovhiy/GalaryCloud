//
//  BackgroundTaskService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 04.12.2025.
//

import Foundation
import Combine
import BackgroundTasks
import UIKit

class BackgroundTaskService: ObservableObject {
    @Published var currentURL: URL?
    
    func configure() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.myTask", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleTask(time: TimeInterval = 1) {
        let request = BGProcessingTaskRequest(identifier: "com.example.myTask")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: time)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule: \(error)")
        }
    }

    let fileManager = FileManagerService()
    
    func handleBackgroundTask(task: BGProcessingTask) {
        task.expirationHandler = {
            // clean up if task is killed by system
            
        }

        Task {
            await self.upload {
                DispatchQueue.main.async {
                    self.currentURL = nil
                }
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    func upload(completion: @escaping()->()) async {
        guard let first = fileManager.loadFiles(.temporary).first else {
            completion()
            return
        }
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.async {
                self.currentURL = first
            }
        }
        await performUpload(first)
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
        return
        
    }
}
