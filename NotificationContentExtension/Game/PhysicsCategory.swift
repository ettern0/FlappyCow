//
//  PhysicsCategory.swift
//  NotificationContentExtension
//
//  Created by Alexey Salangin on 06.04.2022.
//  Copyright © 2022 Granda L. All rights reserved.
//

struct PhysicsCategory {
    static let hero: UInt32 = 1 << 0
    static let land: UInt32 = 1 << 1
    static let pipe: UInt32 = 1 << 2
    static let score: UInt32 = 1 << 3
}
