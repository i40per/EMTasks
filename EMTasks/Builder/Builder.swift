//
//  Builder.swift
//  EMTasks
//
//  Created by Евгений Лукин on 21.03.2026.
//

import UIKit

@MainActor
final class Builder {

    // MARK: - Module
    static func createTasksListModule() -> UIViewController {
        let viewController = TasksListViewController()
        let presenter = TasksListPresenter(view: viewController)

        viewController.presenter = presenter

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isHidden = true

        return navigationController
    }

    static func createTaskDetailsModule(
        task: Task?,
        onSave: ((Task) -> Void)? = nil
    ) -> UIViewController {
        let viewController = TaskDetailsViewController()
        let presenter = TaskDetailsPresenter(
            view: viewController,
            task: task,
            onSave: onSave
        )

        viewController.presenter = presenter

        return viewController
    }
}
