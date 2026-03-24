//
//  TaskDetailsPresenterTests.swift
//  EMTasksTests
//
//  Created by Евгений Лукин on 23.03.2026.
//

import XCTest
@testable import EMTasks

final class TaskDetailsPresenterTests: XCTestCase {

    // MARK: - Tests
    func testViewDidLoad_displaysPassedTask() {
        let view = TaskDetailsViewMock()
        let task = makeTask(title: "Редактируемая задача", description: "Описание")

        let presenter = TaskDetailsPresenter(
            view: view,
            task: task,
            onSave: nil
        )

        presenter.viewDidLoad()

        XCTAssertEqual(view.displayedTask?.id, task.id)
        XCTAssertEqual(view.displayedTask?.title, "Редактируемая задача")
        XCTAssertEqual(view.displayedTask?.taskDescription, "Описание")
    }

    func testDidTapBack_whenNewTaskIsCompletelyEmpty_closesWithoutSaving() {
        let view = TaskDetailsViewMock()
        var savedTask: Task?

        let presenter = TaskDetailsPresenter(
            view: view,
            task: nil,
            onSave: { task in
                savedTask = task
            }
        )

        presenter.didTapBack(title: "   ", description: "   ")

        XCTAssertTrue(view.closeCalled)
        XCTAssertNil(savedTask)
    }

    func testDidTapBack_whenCreatingTaskWithOnlyDescription_savesTaskWithDefaultTitle() {
        let view = TaskDetailsViewMock()
        var savedTask: Task?

        let presenter = TaskDetailsPresenter(
            view: view,
            task: nil,
            onSave: { task in
                savedTask = task
            }
        )

        presenter.didTapBack(title: "   ", description: "Только описание")

        XCTAssertTrue(view.closeCalled)
        XCTAssertEqual(savedTask?.title, "Без названия")
        XCTAssertEqual(savedTask?.taskDescription, "Только описание")
        XCTAssertEqual(savedTask?.serverID, nil)
        XCTAssertEqual(savedTask?.isCompleted, false)
    }

    func testDidTapBack_whenEditingExistingTask_preservesIdentityAndUpdatesFields() {
        let view = TaskDetailsViewMock()
        let originalTask = makeTask(
            title: "Старый title",
            description: "Старое описание",
            isCompleted: true
        )

        var savedTask: Task?

        let presenter = TaskDetailsPresenter(
            view: view,
            task: originalTask,
            onSave: { task in
                savedTask = task
            }
        )

        presenter.didTapBack(title: "Новый title", description: "Новое описание")

        XCTAssertTrue(view.closeCalled)
        XCTAssertEqual(savedTask?.id, originalTask.id)
        XCTAssertEqual(savedTask?.createdAt, originalTask.createdAt)
        XCTAssertEqual(savedTask?.isCompleted, true)
        XCTAssertEqual(savedTask?.title, "Новый title")
        XCTAssertEqual(savedTask?.taskDescription, "Новое описание")
    }
}

// MARK: - Private
private extension TaskDetailsPresenterTests {

    func makeTask(
        title: String,
        description: String,
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

private final class TaskDetailsViewMock: TaskDetailsViewProtocol {

    var displayedTask: Task?
    var closeCalled = false

    func displayTask(_ task: Task?) {
        displayedTask = task
    }

    func close() {
        closeCalled = true
    }
}
