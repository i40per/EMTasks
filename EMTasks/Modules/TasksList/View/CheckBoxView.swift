//
//  CheckBoxView.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import UIKit

final class CheckBoxView: UIControl {

    // MARK: - State
    var isChecked = false {
        didSet {
            applyState()
        }
    }

    // MARK: - Layers
    private let outerLayer = CAShapeLayer()
    private let checkmarkLayer = CAShapeLayer()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = .button

        setupLayers()
        applyState()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        outerLayer.frame = bounds
        outerLayer.path = UIBezierPath(
            ovalIn: bounds.insetBy(dx: 0.5, dy: 0.5)
        ).cgPath

        checkmarkLayer.frame = bounds
        checkmarkLayer.path = makeCheckmarkPath().cgPath

        CATransaction.commit()
    }
}

// MARK: - Private
private extension CheckBoxView {

    func setupLayers() {
        outerLayer.fillColor = UIColor.clear.cgColor
        outerLayer.lineWidth = 1

        checkmarkLayer.strokeColor = UIColor.appAccent.cgColor
        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.lineWidth = 1
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round

        outerLayer.actions = [
            "strokeColor": NSNull(),
            "path": NSNull(),
            "bounds": NSNull(),
            "position": NSNull()
        ]

        checkmarkLayer.actions = [
            "strokeColor": NSNull(),
            "path": NSNull(),
            "bounds": NSNull(),
            "position": NSNull(),
            "hidden": NSNull()
        ]

        layer.addSublayer(outerLayer)
        layer.addSublayer(checkmarkLayer)
    }

    func applyState() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        outerLayer.strokeColor = (isChecked ? UIColor.appAccent : UIColor.appInactiveCircle).cgColor
        checkmarkLayer.isHidden = !isChecked

        CATransaction.commit()
    }

    func makeCheckmarkPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.25, y: bounds.height * 0.54))
        path.addLine(to: CGPoint(x: bounds.width * 0.42, y: bounds.height * 0.72))
        path.addLine(to: CGPoint(x: bounds.width * 0.75, y: bounds.height * 0.30))
        return path
    }

    @objc
    func handleTap() {
        sendActions(for: .valueChanged)
    }
}
