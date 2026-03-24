//
//  UIColor+App.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import UIKit

// MARK: - App Colors
extension UIColor {

    static var appBackground: UIColor {
        UIColor(named: "Background") ?? .black
    }

    static let appSurface = UIColor(red: 39 / 255, green: 39 / 255, blue: 41 / 255, alpha: 1)
    static let appSeparator = UIColor(red: 68 / 255, green: 75 / 255, blue: 83 / 255, alpha: 1)

    static let appTextPrimary = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 1)
    static let appTextSecondary = UIColor(red: 244 / 255, green: 244 / 255, blue: 244 / 255, alpha: 0.5)

    static let appAccent = UIColor(red: 254 / 255, green: 215 / 255, blue: 2 / 255, alpha: 1)
    static let appInactiveCircle = UIColor(red: 78 / 255, green: 88 / 255, blue: 104 / 255, alpha: 1)
}
