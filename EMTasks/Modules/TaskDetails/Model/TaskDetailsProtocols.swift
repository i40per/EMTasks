//
//  TaskDetailsProtocols.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

// MARK: - TaskDetailsViewProtocol
protocol TaskDetailsViewProtocol: AnyObject {
    func displayTask(_ task: Task?)
    func close()
}

// MARK: - TaskDetailsPresenterProtocol
protocol TaskDetailsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapBack(title: String, description: String)
}
