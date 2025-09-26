//
//  Haptics.swift
//  WishListApp
//
//  Created by Nouf Alloboon on 04/04/1447 AH.
//

import Foundation
import UIKit

enum Haptics {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
