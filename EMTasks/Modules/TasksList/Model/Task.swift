//
//  Task.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

// MARK: - Task
struct Task: Equatable {
    let id: UUID
    let serverID: Int?
    var title: String
    var taskDescription: String
    var createdAt: Date
    var isCompleted: Bool
}
