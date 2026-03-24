//
//  APITask.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

// MARK: - APITask
struct APITask: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}
