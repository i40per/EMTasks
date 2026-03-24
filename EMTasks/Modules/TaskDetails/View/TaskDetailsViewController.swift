//
//  TaskDetailsViewController.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import UIKit

final class TaskDetailsViewController: UIViewController {

    // MARK: - Properties
    var presenter: TaskDetailsPresenterProtocol?

    private var currentDate = Date()

    // MARK: - UI
    private let backButton: UIButton = .disableTamic(view: UIButton(type: .system)) {
        let configuration = UIImage.SymbolConfiguration(pointSize: UIView.scaledWidth(17), weight: .regular)
        $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: configuration), for: .normal)
        $0.setTitle(" Назад", for: .normal)
        $0.tintColor = .appAccent
        $0.setTitleColor(.appAccent, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: UIView.scaledWidth(17), weight: .regular)
        $0.contentHorizontalAlignment = .leading
    }

    private let titleContainerView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.appSeparator.cgColor
        $0.layer.cornerRadius = UIView.scaledWidth(12)
        $0.layer.masksToBounds = true
    }

    private let titleTextField: UITextField = .disableTamic(view: UITextField()) {
        let font = UIFont.systemFont(ofSize: UIView.scaledWidth(20), weight: .bold)

        $0.backgroundColor = .clear
        $0.textColor = .appTextPrimary
        $0.tintColor = .appTextPrimary
        $0.font = font
        $0.attributedPlaceholder = NSAttributedString(
            string: "Название задачи",
            attributes: [
                .foregroundColor: UIColor.appTextSecondary,
                .font: font
            ]
        )
        $0.autocorrectionType = .no
        $0.returnKeyType = .done
        $0.clearButtonMode = .never
    }

    private let dateLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.font = .systemFont(ofSize: UIView.scaledWidth(12), weight: .regular)
        $0.textColor = .appTextSecondary
    }

    private let descriptionContainerView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.appSeparator.cgColor
        $0.layer.cornerRadius = UIView.scaledWidth(12)
        $0.layer.masksToBounds = true
    }

    private let descriptionTextView: UITextView = .disableTamic(view: UITextView()) {
        $0.backgroundColor = .clear
        $0.textColor = .appTextPrimary
        $0.font = .systemFont(ofSize: UIView.scaledWidth(16), weight: .regular)
        $0.textContainerInset = UIEdgeInsets(
            top: UIView.scaledHeight(12),
            left: UIView.scaledWidth(12),
            bottom: UIView.scaledHeight(12),
            right: UIView.scaledWidth(12)
        )
        $0.textContainer.lineFragmentPadding = 0
        $0.isScrollEnabled = true
        $0.autocorrectionType = .no
    }

    private let descriptionPlaceholderLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.text = "Описание задачи"
        $0.font = .systemFont(ofSize: UIView.scaledWidth(16), weight: .regular)
        $0.textColor = .appTextSecondary
        $0.numberOfLines = 1
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter?.viewDidLoad()
    }
}

// MARK: - TaskDetailsViewProtocol
extension TaskDetailsViewController: TaskDetailsViewProtocol {

    func displayTask(_ task: Task?) {
        if let task {
            titleTextField.text = task.title
            descriptionTextView.text = task.taskDescription
            currentDate = task.createdAt
        } else {
            titleTextField.text = nil
            descriptionTextView.text = nil
            currentDate = Date()
        }

        dateLabel.text = formatDate(currentDate)
        updateDescriptionPlaceholder()
    }

    func close() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private
private extension TaskDetailsViewController {

    func setupUI() {
        view.backgroundColor = .appBackground

        view.addSubviews(
            backButton,
            titleContainerView,
            dateLabel,
            descriptionContainerView
        )

        titleContainerView.addSubviews(titleTextField)
        descriptionContainerView.addSubviews(descriptionTextView, descriptionPlaceholderLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor,
                                            constant: UIView.scaledHeight(54)),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: UIView.scaledWidth(20)),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -UIView.scaledWidth(20)),
            backButton.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(44)),

            titleContainerView.topAnchor.constraint(equalTo: backButton.bottomAnchor,
                                                    constant: UIView.scaledHeight(12)),
            titleContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: UIView.scaledWidth(20)),
            titleContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -UIView.scaledWidth(20)),
            titleContainerView.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(56)),

            titleTextField.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor,
                                                    constant: UIView.scaledWidth(12)),
            titleTextField.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor,
                                                     constant: -UIView.scaledWidth(12)),
            titleTextField.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor),

            dateLabel.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor,
                                           constant: UIView.scaledHeight(12)),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: UIView.scaledWidth(20)),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -UIView.scaledWidth(20)),
            dateLabel.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(16)),

            descriptionContainerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor,
                                                          constant: UIView.scaledHeight(16)),
            descriptionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                              constant: UIView.scaledWidth(20)),
            descriptionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                               constant: -UIView.scaledWidth(20)),
            descriptionContainerView.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(220)),

            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor),

            descriptionPlaceholderLabel.topAnchor.constraint(
                equalTo: descriptionContainerView.topAnchor,
                constant: UIView.scaledHeight(12)
            ),
            descriptionPlaceholderLabel.leadingAnchor.constraint(
                equalTo: descriptionContainerView.leadingAnchor,
                constant: UIView.scaledWidth(12)
            ),
            descriptionPlaceholderLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: descriptionContainerView.trailingAnchor,
                constant: -UIView.scaledWidth(12)
            )
        ])

        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        titleTextField.delegate = self
        descriptionTextView.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }

    func updateDescriptionPlaceholder() {
        let text = descriptionTextView.text ?? ""
        descriptionPlaceholderLabel.isHidden = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc
    func handleBackTap() {
        presenter?.didTapBack(
            title: titleTextField.text ?? "",
            description: descriptionTextView.text ?? ""
        )
    }

    @objc
    func handleBackgroundTap() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension TaskDetailsViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate
extension TaskDetailsViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updateDescriptionPlaceholder()
    }
}
