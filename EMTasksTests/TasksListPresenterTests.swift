//
//  TasksListPresenterTests.swift
//  EMTasksTests
//
//  Created by Евгений Лукин on 23.03.2026.
//

import XCTest
@testable import EMTasks

final class TasksListPresenterTests: XCTestCase {

    // MARK: - Tests
    func testViewDidLoad_whenStoredTasksExist_displaysStoredTasks() {
        let view = TasksListViewMock()
        let storage = StorageServiceMock()
        let network = NetworkServiceMock()

        let tasks = [
            makeTask(title: "Первая задача"),
            makeTask(title: "Вторая задача")
        ]

        storage.tasksToFetch = tasks

        let presenter = TasksListPresenter(
            view: view,
            storageService: storage,
            networkService: network
        )

        let displayExpectation = expectation(description: "display stored tasks")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 2 {
                displayExpectation.fulfill()
            }
        }

        presenter.viewDidLoad()

        wait(for: [displayExpectation], timeout: 1.0)

        XCTAssertEqual(view.displayedTasks.count, 2)
        XCTAssertEqual(view.displayedTasks.first?.title, "Первая задача")
        XCTAssertEqual(view.displayedCount, 2)
        XCTAssertFalse(network.fetchTasksCalled)
    }

    func testViewDidLoad_whenStorageIsEmptyAndInitialImportNotCompleted_loadsTasksFromNetwork() {
        let view = TasksListViewMock()
        let storage = StorageServiceMock()
        let network = NetworkServiceMock()

        storage.tasksToFetch = []
        storage.initialImportCompleted = false
        network.tasksToReturn = [
            APITask(id: 101, todo: "Задача из сети", completed: true)
        ]

        let presenter = TasksListPresenter(
            view: view,
            storageService: storage,
            networkService: network
        )

        let displayExpectation = expectation(description: "display imported tasks")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 1 {
                displayExpectation.fulfill()
            }
        }

        presenter.viewDidLoad()

        wait(for: [displayExpectation], timeout: 1.0)

        XCTAssertTrue(network.fetchTasksCalled)
        XCTAssertEqual(view.displayedTasks.count, 1)
        XCTAssertEqual(view.displayedCount, 1)
        XCTAssertEqual(storage.replacedTasks.last?.count, 1)
        XCTAssertTrue(storage.setInitialImportCompletedCalled)
    }

    func testDidSearch_filtersTasksByTitleAndDescription() {
        let view = TasksListViewMock()
        let storage = StorageServiceMock()
        let network = NetworkServiceMock()

        let firstTask = makeTask(
            title: "Уборка",
            description: "Протереть пыль"
        )

        let secondTask = makeTask(
            title: "Тренировка",
            description: "Сходить в спортзал вечером"
        )

        storage.tasksToFetch = [firstTask, secondTask]

        let presenter = TasksListPresenter(
            view: view,
            storageService: storage,
            networkService: network
        )

        let initialLoadExpectation = expectation(description: "initial load")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 2 {
                initialLoadExpectation.fulfill()
            }
        }

        presenter.viewDidLoad()
        wait(for: [initialLoadExpectation], timeout: 1.0)

        let searchExpectation = expectation(description: "filtered tasks")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 1, displayedTasks.first?.title == "Тренировка" {
                searchExpectation.fulfill()
            }
        }

        presenter.didSearch(text: "спорт")

        wait(for: [searchExpectation], timeout: 1.0)

        XCTAssertEqual(view.displayedTasks.count, 1)
        XCTAssertEqual(view.displayedTasks.first?.title, "Тренировка")
    }

    func testDidToggleTask_updatesTaskAndPersistsChanges() {
        let view = TasksListViewMock()
        let storage = StorageServiceMock()
        let network = NetworkServiceMock()

        let task = makeTask(
            title: "Чекбокс",
            isCompleted: false
        )

        storage.tasksToFetch = [task]

        let presenter = TasksListPresenter(
            view: view,
            storageService: storage,
            networkService: network
        )

        let loadExpectation = expectation(description: "load before toggle")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 1 {
                loadExpectation.fulfill()
            }
        }

        presenter.viewDidLoad()
        wait(for: [loadExpectation], timeout: 1.0)

        presenter.didToggleTask(at: 0)

        XCTAssertEqual(view.updatedTask?.title, "Чекбокс")
        XCTAssertEqual(view.updatedTaskIndex, 0)
        XCTAssertTrue(view.updatedTask?.isCompleted == true)
        XCTAssertTrue(storage.replacedTasks.last?.first?.isCompleted == true)
    }

    func testDidDeleteTask_removesTaskAndPersistsChanges() {
        let view = TasksListViewMock()
        let storage = StorageServiceMock()
        let network = NetworkServiceMock()

        let firstTask = makeTask(title: "Первая")
        let secondTask = makeTask(title: "Вторая")

        storage.tasksToFetch = [firstTask, secondTask]

        let presenter = TasksListPresenter(
            view: view,
            storageService: storage,
            networkService: network
        )

        let loadExpectation = expectation(description: "load before delete")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 2 {
                loadExpectation.fulfill()
            }
        }

        presenter.viewDidLoad()
        wait(for: [loadExpectation], timeout: 1.0)

        let deleteExpectation = expectation(description: "display after delete")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 1 {
                deleteExpectation.fulfill()
            }
        }

        presenter.didDeleteTask(at: 0)

        wait(for: [deleteExpectation], timeout: 1.0)

        XCTAssertEqual(view.displayedTasks.count, 1)
        XCTAssertEqual(view.displayedCount, 1)
        XCTAssertEqual(storage.replacedTasks.last?.count, 1)
        XCTAssertEqual(storage.replacedTasks.last?.first?.title, "Вторая")
    }

    func testDidTapCreateTask_opensTaskDetailsForNewTask() {
        let view = TasksListViewMock()
        let storage = StorageServiceMock()
        let network = NetworkServiceMock()

        let presenter = TasksListPresenter(
            view: view,
            storageService: storage,
            networkService: network
        )

        presenter.didTapCreateTask()

        XCTAssertTrue(view.showTaskDetailsCalled)
        XCTAssertNil(view.shownTask)
        XCTAssertNotNil(view.onSave)
    }

    func testDidSelectTask_opensTaskDetailsForSelectedTask() {
        let view = TasksListViewMock()
        let storage = StorageServiceMock()
        let network = NetworkServiceMock()

        let task = makeTask(title: "Открыть детали")
        storage.tasksToFetch = [task]

        let presenter = TasksListPresenter(
            view: view,
            storageService: storage,
            networkService: network
        )

        let loadExpectation = expectation(description: "load before select")
        view.onDisplayTasks = { displayedTasks in
            if displayedTasks.count == 1 {
                loadExpectation.fulfill()
            }
        }

        presenter.viewDidLoad()
        wait(for: [loadExpectation], timeout: 1.0)

        presenter.didSelectTask(at: 0)

        XCTAssertTrue(view.showTaskDetailsCalled)
        XCTAssertEqual(view.shownTask?.id, task.id)
        XCTAssertEqual(view.shownTask?.title, "Открыть детали")
        XCTAssertNotNil(view.onSave)
    }
}

// MARK: - Private
private extension TasksListPresenterTests {

    func makeTask(
        title: String,
        description: String = "Описание",
        isCompleted: Bool = false
    ) -> Task {
        Task(
            id: UUID(),
            serverID: nil,
            title: title,
            taskDescription: description,
            createdAt: Date(),
            isCompleted: isCompleted
        )
    }
}

private final class TasksListViewMock: TasksListViewProtocol {

    var displayedTasks: [Task] = []
    var displayedCount = 0

    var updatedTask: Task?
    var updatedTaskIndex: Int?

    var removedTaskIndex: Int?
    var removedTotalCount: Int?

    var showTaskDetailsCalled = false
    var shownTask: Task?
    var onSave: ((Task) -> Void)?

    var onDisplayTasks: (([Task]) -> Void)?

    func displayTasks(_ tasks: [Task]) {
        displayedTasks = tasks
        onDisplayTasks?(tasks)
    }

    func displayTasksCount(_ count: Int) {
        displayedCount = count
    }

    func updateTask(_ task: Task, at index: Int, totalCount: Int) {
        updatedTask = task
        updatedTaskIndex = index
        displayedCount = totalCount
    }

    func removeTask(at index: Int, totalCount: Int) {
        removedTaskIndex = index
        removedTotalCount = totalCount
    }

    func showTaskDetails(task: Task?, onSave: ((Task) -> Void)?) {
        showTaskDetailsCalled = true
        shownTask = task
        self.onSave = onSave
    }
}

private final class StorageServiceMock: StorageServiceProtocol {

    var tasksToFetch: [Task] = []
    var replacedTasks: [[Task]] = []

    var initialImportCompleted = false
    var setInitialImportCompletedCalled = false

    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        completion(tasksToFetch)
    }

    func replaceTasks(with tasks: [Task], completion: (() -> Void)?) {
        replacedTasks.append(tasks)
        completion?()
    }

    func isInitialImportCompleted() -> Bool {
        initialImportCompleted
    }

    func setInitialImportCompleted() {
        initialImportCompleted = true
        setInitialImportCompletedCalled = true
    }
}

private final class NetworkServiceMock: NetworkServiceProtocol {

    var fetchTasksCalled = false
    var tasksToReturn: [APITask] = []

    func fetchTasks(completion: @escaping ([APITask]) -> Void) {
        fetchTasksCalled = true
        completion(tasksToReturn)
    }
}
