//
//  TaskCell.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import UIKit

final class TaskCell: UITableViewCell {

    // MARK: - Constants
    static let reuseIdentifier = "TaskCell"

    // MARK: - State
    private var onToggle: (() -> Void)?
    private var currentTask: Task?

    private var descriptionHeightConstraint: NSLayoutConstraint?
    private var dateTopConstraint: NSLayoutConstraint?

    // MARK: - UI
    private let checkBoxView: CheckBoxView = .disableTamic(view: CheckBoxView()) {
        $0.widthAnchor.constraint(equalToConstant: UIView.scaledLayout(24)).isActive = true
        $0.heightAnchor.constraint(equalToConstant: UIView.scaledLayout(24)).isActive = true
    }

    private let titleLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.font = .systemFont(ofSize: UIView.scaledLayout(16), weight: .medium)
        $0.textColor = .appTextPrimary
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let descriptionLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.font = .systemFont(ofSize: UIView.scaledLayout(12), weight: .regular)
        $0.textColor = .appTextSecondary
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
    }

    private let dateLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.font = .systemFont(ofSize: UIView.scaledLayout(12), weight: .regular)
        $0.textColor = .appTextSecondary
        $0.numberOfLines = 1
    }

    private let separatorView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .appSeparator
    }

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        setupLayout()
        checkBoxView.addTarget(self, action: #selector(handleCheckBoxTap), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        currentTask = nil
    }

    // MARK: - Configuration
    func configure(task: Task, onToggle: @escaping () -> Void) {
        self.onToggle = onToggle
        self.currentTask = task

        checkBoxView.isChecked = task.isCompleted
        titleLabel.attributedText = makeTitleText(task: task)
        descriptionLabel.text = task.taskDescription
        dateLabel.text = formatDate(task.createdAt)

        descriptionLabel.textColor = task.isCompleted ? .appTextSecondary : .appTextPrimary
        dateLabel.textColor = .appTextSecondary

        applyDescriptionLayout(for: task)
    }

    func makeContextMenuPreview() -> UITargetedPreview {
        let previewView = makePreviewView()

        let target = UIPreviewTarget(
            container: contentView,
            center: CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY)
        )

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: previewView.bounds,
            cornerRadius: UIView.scaledLayout(12)
        )

        return UITargetedPreview(view: previewView, parameters: parameters, target: target)
    }
}

// MARK: - Private

private extension TaskCell {

    func setupLayout() {
        contentView.addSubviews(checkBoxView, titleLabel, descriptionLabel, dateLabel, separatorView)

        descriptionHeightConstraint =
        descriptionLabel.heightAnchor.constraint(equalToConstant: UIView.scaledLayout(32))
        dateTopConstraint =
        dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,
                                       constant: UIView.scaledLayout(6))

        NSLayoutConstraint.activate([
            checkBoxView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                  constant: UIView.scaledWidth(20)),
            checkBoxView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                              constant: UIView.scaledLayout(12)),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: UIView.scaledWidth(52)),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                 constant: -UIView.scaledWidth(20)),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: UIView.scaledLayout(12)),
            titleLabel.heightAnchor.constraint(equalToConstant: UIView.scaledLayout(22)),

            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: UIView.scaledWidth(52)),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: -UIView.scaledWidth(20)),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                  constant: UIView.scaledLayout(6)),

            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: UIView.scaledWidth(52)),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -UIView.scaledWidth(20)),
            dateLabel.heightAnchor.constraint(equalToConstant: UIView.scaledLayout(16)),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -UIView.scaledLayout(12)),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: UIView.scaledWidth(20)),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -UIView.scaledWidth(20)),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])

        if let descriptionHeightConstraint, let dateTopConstraint {
            NSLayoutConstraint.activate([descriptionHeightConstraint, dateTopConstraint])
        }
    }

    func applyDescriptionLayout(for task: Task) {
        let isMultiline = isDescriptionMultiline(task.taskDescription)

        descriptionHeightConstraint?.constant = isMultiline
            ? UIView.scaledLayout(32)
            : UIView.scaledLayout(16)

        layoutIfNeeded()
    }

    func isDescriptionMultiline(_ text: String) -> Bool {
        let font = UIFont.systemFont(ofSize: UIView.scaledLayout(12), weight: .regular)
        let availableWidth = UIScreen.main.bounds.width - UIView.scaledWidth(52) - UIView.scaledWidth(20)

        let boundingRect = NSString(string: text).boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )

        return boundingRect.height > font.lineHeight * 1.2
    }

    func makeTitleText(task: Task) -> NSAttributedString {
        let color = task.isCompleted ? UIColor.appTextSecondary : UIColor.appTextPrimary

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: UIView.scaledLayout(16), weight: .medium),
            .foregroundColor: color,
            .strikethroughStyle: task.isCompleted ? NSUnderlineStyle.single.rawValue : 0,
            .strikethroughColor: color
        ]

        return NSAttributedString(string: task.title, attributes: attributes)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }

    func makePreviewView() -> UIView {
        let isMultiline = currentTask.map { isDescriptionMultiline($0.taskDescription) } ?? false
        let previewWidth = contentView.bounds.width - (UIView.scaledWidth(20) * 2)
        let previewHeight = isMultiline ? UIView.scaledLayout(106) : UIView.scaledLayout(90)
        let descriptionHeight = isMultiline ? UIView.scaledLayout(32) : UIView.scaledLayout(16)

        let previewView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: previewWidth,
            height: previewHeight
        ))
        previewView.backgroundColor = .appSurface
        previewView.layer.cornerRadius = UIView.scaledLayout(12)
        previewView.layer.masksToBounds = true

        let previewTitleLabel: UILabel = .disableTamic(view: UILabel()) {
            $0.font = .systemFont(ofSize: UIView.scaledLayout(16), weight: .medium)
            $0.textColor = titleLabel.textColor
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
            $0.attributedText = titleLabel.attributedText
        }

        let previewDescriptionLabel: UILabel = .disableTamic(view: UILabel()) {
            $0.font = .systemFont(ofSize: UIView.scaledLayout(12), weight: .regular)
            $0.textColor = descriptionLabel.textColor
            $0.numberOfLines = isMultiline ? 2 : 1
            $0.lineBreakMode = .byTruncatingTail
            $0.text = descriptionLabel.text
        }

        let previewDateLabel: UILabel = .disableTamic(view: UILabel()) {
            $0.font = .systemFont(ofSize: UIView.scaledLayout(12), weight: .regular)
            $0.textColor = dateLabel.textColor
            $0.numberOfLines = 1
            $0.text = dateLabel.text
        }

        previewView.addSubviews(previewTitleLabel, previewDescriptionLabel, previewDateLabel)

        NSLayoutConstraint.activate([
            previewTitleLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor,
                                                       constant: UIView.scaledLayout(16)),
            previewTitleLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor,
                                                        constant: -UIView.scaledLayout(16)),
            previewTitleLabel.topAnchor.constraint(equalTo: previewView.topAnchor,
                                                   constant: UIView.scaledLayout(12)),
            previewTitleLabel.heightAnchor.constraint(equalToConstant: UIView.scaledLayout(22)),

            previewDescriptionLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor,
                                                             constant: UIView.scaledLayout(16)),
            previewDescriptionLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor,
                                                              constant: -UIView.scaledLayout(16)),
            previewDescriptionLabel.topAnchor.constraint(equalTo: previewTitleLabel.bottomAnchor,
                                                         constant: UIView.scaledLayout(6)),
            previewDescriptionLabel.heightAnchor.constraint(equalToConstant: descriptionHeight),

            previewDateLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor,
                                                      constant: UIView.scaledLayout(16)),
            previewDateLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor,
                                                       constant: -UIView.scaledLayout(16)),
            previewDateLabel.topAnchor.constraint(equalTo: previewDescriptionLabel.bottomAnchor,
                                                  constant: UIView.scaledLayout(6)),
            previewDateLabel.heightAnchor.constraint(equalToConstant: UIView.scaledLayout(16))
        ])

        previewView.layoutIfNeeded()

        return previewView
    }

    @objc
    func handleCheckBoxTap() {
        onToggle?()
    }
}
