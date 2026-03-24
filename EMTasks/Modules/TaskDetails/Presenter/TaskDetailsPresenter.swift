//
//  TaskDetailsPresenter.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

final class TaskDetailsPresenter: TaskDetailsPresenterProtocol {

    // MARK: - Properties
    weak var view: TaskDetailsViewProtocol?

    private let task: Task?
    private let onSave: ((Task) -> Void)?

    // MARK: - Initialization
    init(
        view: TaskDetailsViewProtocol,
        task: Task?,
        onSave: ((Task) -> Void)?
    ) {
        self.view = view
        self.task = task
        self.onSave = onSave
    }

    // MARK: - TaskDetailsPresenterProtocol
    func viewDidLoad() {
        view?.displayTask(task)
    }

    func didTapBack(title: String, description: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        if task == nil, trimmedTitle.isEmpty, trimmedDescription.isEmpty {
            view?.close()
            return
        }

        let savedTask = makeTask(
            title: trimmedTitle,
            description: trimmedDescription
        )

        onSave?(savedTask)
        view?.close()
    }
}

// MARK: - Private
private extension TaskDetailsPresenter {

    func makeTask(title: String, description: String) -> Task {
        let resolvedTitle: String

        if title.isEmpty {
            resolvedTitle = "Без названия"
        } else {
            resolvedTitle = title
        }

        if let task {
            return Task(
                id: task.id,
                serverID: task.serverID,
                title: resolvedTitle,
                taskDescription: description,
                createdAt: task.createdAt,
                isCompleted: task.isCompleted
            )
        } else {
            return Task(
                id: UUID(),
                serverID: nil,
                title: resolvedTitle,
                taskDescription: description,
                createdAt: Date(),
                isCompleted: false
            )
        }
    }
}
