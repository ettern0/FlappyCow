//
//  PushController.swift
//  PushGame
//
//  Created by Alexey Salangin on 07.04.2022.
//

import Foundation
import UserNotifications

final class PushController: NSObject {
    private let center = UNUserNotificationCenter.current()

    func prepare() {
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("Notifications permission granted.")
            }
            else {
                print("Notifications permission denied because: \(error?.localizedDescription ?? "Unknown error").")
            }
        }

        let timeToPlayNotificationCategory = UNNotificationCategory(
            identifier: "timeToPlayNotification",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([timeToPlayNotificationCategory])

        center.delegate = self
    }

    func registerPush(with time: Time) {
        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }

            guard settings.authorizationStatus == .authorized else {
                // TODO: Open Settings.
                return
            }
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "timeToPlayNotification"

            content.title = "Time to play!"
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time.timeInterval, repeats: false)

            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            self.center.add(request, withCompletionHandler: nil)
        }
    }
}

extension PushController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.sound, .list, .banner])
    }
}
