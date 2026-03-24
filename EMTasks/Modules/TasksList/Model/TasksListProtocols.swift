//
//  TasksListProtocols.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

// MARK: - TasksListViewProtocol
protocol TasksListViewProtocol: AnyObject {
    func displayTasks(_ tasks: [Task])
    func displayTasksCount(_ count: Int)
    func updateTask(_ task: Task, at index: Int, totalCount: Int)
    func removeTask(at index: Int, totalCount: Int)
    func showTaskDetails(task: Task?, onSave: ((Task) -> Void)?)
}

// MARK: - TasksListPresenterProtocol
protocol TasksListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectTask(at index: Int)
    func didTapCreateTask()
    func didToggleTask(at index: Int)
    func didDeleteTask(at index: Int)
    func didSearch(text: String)
}
