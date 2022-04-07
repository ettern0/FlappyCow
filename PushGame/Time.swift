//
//  Time.swift
//  PushGame
//
//  Created by Alexey Salangin on 07.04.2022.
//

enum Time: CaseIterable {
    case sec5
    case min1
    case min5
    case random

    var textValue: String {
        switch self {
        case .sec5:
            return "5 sec."
        case .min1:
            return "1 min."
        case .min5:
            return "5 min."
        case .random:
            return "Random"
        }
    }
}
