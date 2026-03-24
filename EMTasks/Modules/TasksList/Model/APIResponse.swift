//
//  APIResponse.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

// MARK: - APIResponse
struct APIResponse: Decodable {
    let todos: [APITask]
}
