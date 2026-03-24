//
//  UIView+Tamic.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import UIKit

// MARK: - UIView Layout Utilities
extension UIView {

    // MARK: - Layout Helpers
    static func disableTamic<T: UIView>(view: T, completion: (T) -> Void) -> T {
        view.translatesAutoresizingMaskIntoConstraints = false
        completion(view)
        return view
    }

    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    func superview<T>(of type: T.Type) -> T? {
        var view: UIView? = self

        while let currentView = view {
            if let typedView = currentView as? T {
                return typedView
            }

            view = currentView.superview
        }

        return nil
    }

    // MARK: - Scaling Helpers
    static func scaledWidth(_ value: CGFloat) -> CGFloat {
        UIScreen.main.bounds.width * (value / 360)
    }

    static func scaledHeight(_ value: CGFloat) -> CGFloat {
        UIScreen.main.bounds.height * (value / 800)
    }

    static func scaledLayout(_ value: CGFloat) -> CGFloat {
        let widthScale = UIScreen.main.bounds.width / 360
        let heightScale = UIScreen.main.bounds.height / 800
        let layoutScale = min(widthScale, heightScale)

        return value * layoutScale
    }
}
