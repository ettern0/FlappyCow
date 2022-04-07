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
import SpriteKit

class NotificationViewController: UIViewController {
    private lazy var scene: GameScene? = {
        $0?.scaleMode = .aspectFill
        return $0
    }(GameScene(fileNamed: "GameScene"))

    override func loadView() {
        view = {
            $0.ignoresSiblingOrder = true
            $0.showsFPS = false
            $0.showsNodeCount = false
            return $0
        }(SKView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let scene = scene, let skView = self.view as? SKView else { return }
        skView.presentScene(scene)
        becomeFirstResponder()
    }
}

extension NotificationViewController: UNNotificationContentExtension {
    func didReceive(_ notification: UNNotification) {
    }
}
