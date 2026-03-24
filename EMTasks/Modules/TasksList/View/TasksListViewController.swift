//
//  TasksListViewController.swift
//  EMTasks
//
//  Created by Евгений Лукин on 21.03.2026.
//

import UIKit

final class TasksListViewController: UIViewController {

    // MARK: - Properties
    var presenter: TasksListPresenterProtocol?

    private var tasks: [Task] = []
    private var shouldIgnoreNextSelection = false

    // MARK: - UI
    private let titleLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.text = "Задачи"
        $0.font = .systemFont(ofSize: UIView.scaledWidth(34), weight: .bold)
        $0.textColor = .appTextPrimary
    }

    private let searchContainerView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .clear
    }

    private let searchInputView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .appSurface
        $0.layer.cornerRadius = UIView.scaledWidth(10)
        $0.layer.masksToBounds = true
    }

    private let searchIconView: UIImageView = .disableTamic(view: UIImageView()) {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: UIView.scaledWidth(16),
            weight: .regular
        )
        $0.image = UIImage(systemName: "magnifyingglass", withConfiguration: configuration)
        $0.tintColor = .appTextSecondary
        $0.contentMode = .scaleAspectFit
    }

    private let searchTextField: UITextField = .disableTamic(view: UITextField()) {
        $0.backgroundColor = .clear
        $0.textColor = .appTextPrimary
        $0.tintColor = .appTextPrimary
        $0.font = .systemFont(ofSize: UIView.scaledWidth(20), weight: .regular)
        $0.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [
                .foregroundColor: UIColor.appTextSecondary,
                .font: UIFont.systemFont(ofSize: UIView.scaledWidth(20), weight: .regular)
            ]
        )
        $0.returnKeyType = .done
        $0.clearButtonMode = .never
    }

    private let microphoneButton: UIButton = .disableTamic(view: UIButton(type: .system)) {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: UIView.scaledWidth(16),
            weight: .regular
        )
        $0.setImage(UIImage(systemName: "mic.fill", withConfiguration: configuration), for: .normal)
        $0.tintColor = .appTextSecondary
    }

    private let tableView: UITableView = .disableTamic(view: UITableView(frame: .zero, style: .plain)) {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIView.scaledHeight(83), right: 0)
        $0.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = UIView.scaledLayout(90)
    }

    private let emptyStateContainerView: UIView = .disableTamic(view: UIView()) {
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = .clear
    }

    private let emptyStateImageView: UIImageView = .disableTamic(view: UIImageView()) {
        $0.image = UIImage(named: "emptyStateTasks")
        $0.contentMode = .scaleAspectFit
    }

    private let emptyStateLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.text = "Create your first task to get started"
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = .appTextSecondary
        $0.font = .systemFont(ofSize: UIView.scaledWidth(16), weight: .regular)
    }

    private let footerView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .appSurface
    }

    private let footerTopContentView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .clear
    }

    private let footerBottomInsetView: UIView = .disableTamic(view: UIView()) {
        $0.backgroundColor = .appSurface
    }

    private let tasksCountLabel: UILabel = .disableTamic(view: UILabel()) {
        $0.font = .systemFont(ofSize: UIView.scaledWidth(11), weight: .regular)
        $0.textColor = .appTextPrimary
        $0.textAlignment = .center
    }

    private let addButton: UIButton = .disableTamic(view: UIButton(type: .system)) {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: UIView.scaledWidth(22),
            weight: .regular
        )
        $0.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: configuration), for: .normal)
        $0.tintColor = .appAccent
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter?.viewDidLoad()
    }
}

// MARK: - TasksListViewProtocol
extension TasksListViewController: TasksListViewProtocol {

    func displayTasks(_ tasks: [Task]) {
        self.tasks = tasks

        UIView.performWithoutAnimation {
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }

        updateEmptyStateVisibility()
    }

    func displayTasksCount(_ count: Int) {
        tasksCountLabel.text = "\(count) Задач"
    }

    func updateTask(_ task: Task, at index: Int, totalCount: Int) {
        guard index < tasks.count else { return }

        tasks[index] = task
        tasksCountLabel.text = "\(totalCount) Задач"

        let indexPath = IndexPath(row: index, section: 0)

        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.layoutIfNeeded()
        }
    }

    func removeTask(at index: Int, totalCount: Int) {
        guard index < tasks.count else { return }

        tasks.remove(at: index)
        tasksCountLabel.text = "\(totalCount) Задач"

        let indexPath = IndexPath(row: index, section: 0)
        tableView.performBatchUpdates {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        updateEmptyStateVisibility()
    }

    func showTaskDetails(task: Task?, onSave: ((Task) -> Void)?) {
        let viewController = Builder.createTaskDetailsModule(task: task, onSave: onSave)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Private
private extension TasksListViewController {

    func setupUI() {
        view.backgroundColor = .appBackground

        setupHierarchy()
        setupConstraints()
        setupTable()
        setupActions()
    }

    func setupHierarchy() {
        view.addSubviews(titleLabel, searchContainerView, tableView, emptyStateContainerView, footerView)

        searchContainerView.addSubviews(searchInputView)
        searchInputView.addSubviews(searchIconView, searchTextField, microphoneButton)
        emptyStateContainerView.addSubviews(emptyStateImageView, emptyStateLabel)

        footerView.addSubviews(footerTopContentView, footerBottomInsetView)
        footerTopContentView.addSubviews(tasksCountLabel, addButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor,
                                            constant: UIView.scaledHeight(64)),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: UIView.scaledWidth(20)),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -UIView.scaledWidth(20)),
            titleLabel.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(41)),

            searchContainerView.topAnchor.constraint(equalTo: view.topAnchor,
                                                     constant: UIView.scaledHeight(120)),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                         constant: UIView.scaledWidth(20)),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                          constant: -UIView.scaledWidth(20)),
            searchContainerView.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(52)),

            searchInputView.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchInputView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            searchInputView.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            searchInputView.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(36)),

            searchIconView.leadingAnchor.constraint(equalTo: searchInputView.leadingAnchor,
                                                    constant: UIView.scaledWidth(12)),
            searchIconView.centerYAnchor.constraint(equalTo: searchInputView.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: UIView.scaledWidth(18)),
            searchIconView.heightAnchor.constraint(equalToConstant: UIView.scaledWidth(18)),

            microphoneButton.trailingAnchor.constraint(equalTo: searchInputView.trailingAnchor,
                                                       constant: -UIView.scaledWidth(12)),
            microphoneButton.centerYAnchor.constraint(equalTo: searchInputView.centerYAnchor),
            microphoneButton.widthAnchor.constraint(equalToConstant: UIView.scaledWidth(18)),
            microphoneButton.heightAnchor.constraint(equalToConstant: UIView.scaledWidth(18)),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor,
                                                     constant: UIView.scaledWidth(8)),
            searchTextField.trailingAnchor.constraint(equalTo: microphoneButton.leadingAnchor,
                                                      constant: -UIView.scaledWidth(8)),
            searchTextField.centerYAnchor.constraint(equalTo: searchInputView.centerYAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(36)),

            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            emptyStateContainerView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            emptyStateContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateContainerView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateContainerView.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: emptyStateContainerView.centerYAnchor,
                                                         constant: -UIView.scaledHeight(20)),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: UIView.scaledWidth(260)),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(260)),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor,
                                                 constant: UIView.scaledHeight(16)),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateContainerView.leadingAnchor,
                                                     constant: UIView.scaledWidth(32)),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContainerView.trailingAnchor,
                                                      constant: -UIView.scaledWidth(32)),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(83)),

            footerTopContentView.topAnchor.constraint(equalTo: footerView.topAnchor),
            footerTopContentView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            footerTopContentView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            footerTopContentView.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(49)),

            footerBottomInsetView.topAnchor.constraint(equalTo: footerTopContentView.bottomAnchor),
            footerBottomInsetView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            footerBottomInsetView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            footerBottomInsetView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),

            tasksCountLabel.centerXAnchor.constraint(equalTo: footerTopContentView.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: footerTopContentView.centerYAnchor),

            addButton.trailingAnchor.constraint(equalTo: footerTopContentView.trailingAnchor,
                                                constant: -UIView.scaledWidth(20)),
            addButton.centerYAnchor.constraint(equalTo: footerTopContentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: UIView.scaledWidth(68)),
            addButton.heightAnchor.constraint(equalToConstant: UIView.scaledHeight(44))
        ])
    }

    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }

    func setupActions() {
        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(handleSearchChange), for: .editingChanged)
        searchTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    func updateEmptyStateVisibility() {
        let isEmpty = tasks.isEmpty

        emptyStateContainerView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    @objc
    func handleAddButtonTap() {
        presenter?.didTapCreateTask()
    }

    @objc
    func handleSearchChange() {
        presenter?.didSearch(text: searchTextField.text ?? "")
    }

    @objc
    func handleBackgroundTap() {
        if searchTextField.isFirstResponder {
            shouldIgnoreNextSelection = true
        }

        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let task = tasks[indexPath.row]

        let descriptionFont = UIFont.systemFont(ofSize: UIView.scaledLayout(12), weight: .regular)
        let availableWidth = UIScreen.main.bounds.width - UIView.scaledWidth(52) - UIView.scaledWidth(20)

        let boundingRect = NSString(string: task.taskDescription).boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: descriptionFont],
            context: nil
        )

        let oneLineHeight = descriptionFont.lineHeight

        return boundingRect.height > oneLineHeight * 1.2
            ? UIView.scaledLayout(106)
            : UIView.scaledLayout(90)
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskCell.reuseIdentifier,
            for: indexPath
        ) as? TaskCell else {
            return UITableViewCell()
        }

        let task = tasks[indexPath.row]

        cell.configure(task: task) { [weak self] in
            self?.presenter?.didToggleTask(at: indexPath.row)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldIgnoreNextSelection {
            shouldIgnoreNextSelection = false
            return
        }

        if searchTextField.isFirstResponder {
            shouldIgnoreNextSelection = false
            view.endEditing(true)
            return
        }

        presenter?.didSelectTask(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }

            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "square.and.pencil")
            ) { [weak self] _ in
                self?.presenter?.didSelectTask(at: indexPath.row)
            }

            let shareAction = UIAction(
                title: "Поделиться",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { [weak self] _ in
                guard let self else { return }

                let task = self.tasks[indexPath.row]
                let text = "\(task.title)\n\(task.taskDescription)"

                let activityController = UIActivityViewController(
                    activityItems: [text],
                    applicationActivities: nil
                )

                self.present(activityController, animated: true)
            }

            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.presenter?.didDeleteTask(at: indexPath.row)
            }

            return UIMenu(children: [editAction, shareAction, deleteAction])
        }
    }

    func tableView(
        _ tableView: UITableView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? TaskCell
        else {
            return nil
        }

        return cell.makeContextMenuPreview()
    }

    func tableView(
        _ tableView: UITableView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? TaskCell
        else {
            return nil
        }

        return cell.makeContextMenuPreview()
    }
}

// MARK: - UITextFieldDelegate
extension TasksListViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
