//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Alexey Salangin on 07.04.2022.
//  Copyright © 2022 Granda L. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = "notification.request.content.body"
    }

}
