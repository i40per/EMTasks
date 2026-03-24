//
//  StorageService.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

// MARK: - StorageServiceProtocol
protocol StorageServiceProtocol: AnyObject {
    func fetchTasks(completion: @escaping ([Task]) -> Void)
    func replaceTasks(with tasks: [Task], completion: (() -> Void)?)

    func isInitialImportCompleted() -> Bool
    func setInitialImportCompleted()
}

// MARK: - StorageService
final class StorageService: StorageServiceProtocol {

    // MARK: - Dependencies
    private let coreDataManager: CoreDataManager
    private let userDefaults: UserDefaults

    // MARK: - Properties
    private let initialImportCompletedKey = "initialImportCompletedKey"

    // MARK: - Initialization
    init(
        coreDataManager: CoreDataManager = .shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.coreDataManager = coreDataManager
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods
    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        coreDataManager.fetchTasks(completion: completion)
    }

    func replaceTasks(with tasks: [Task], completion: (() -> Void)? = nil) {
        coreDataManager.replaceTasks(with: tasks, completion: completion)
    }

    func isInitialImportCompleted() -> Bool {
        userDefaults.bool(forKey: initialImportCompletedKey)
    }

    func setInitialImportCompleted() {
        userDefaults.set(true, forKey: initialImportCompletedKey)
    }
}
