//
//  TasksListPresenter.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import Foundation

final class TasksListPresenter: TasksListPresenterProtocol {

    // MARK: - Properties
    weak var view: TasksListViewProtocol?

    private let storageService: StorageServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let workQueue = DispatchQueue(label: "emtasks.presenter.queue", qos: .userInitiated)

    // MARK: - State
    private var tasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var currentSearchText = ""

    // MARK: - Initialization
    init(
        view: TasksListViewProtocol,
        storageService: StorageServiceProtocol = StorageService(),
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.view = view
        self.storageService = storageService
        self.networkService = networkService
    }

    // MARK: - TasksListPresenterProtocol
    func viewDidLoad() {
        loadTasks()
    }

    func didSelectTask(at index: Int) {
        guard index >= 0, index < filteredTasks.count else { return }

        let selectedTask = filteredTasks[index]

        view?.showTaskDetails(task: selectedTask, onSave: { [weak self] updatedTask in
            self?.saveTask(updatedTask)
        })
    }

    func didTapCreateTask() {
        view?.showTaskDetails(task: nil, onSave: { [weak self] newTask in
            self?.saveTask(newTask)
        })
    }

    func didToggleTask(at index: Int) {
        guard index >= 0, index < filteredTasks.count else { return }

        let selectedTaskID = filteredTasks[index].id

        guard let sourceIndex = tasks.firstIndex(where: { $0.id == selectedTaskID }) else { return }

        tasks[sourceIndex].isCompleted.toggle()

        guard let filteredIndex = filteredTasks.firstIndex(where: { $0.id == selectedTaskID }) else { return }

        filteredTasks[filteredIndex] = tasks[sourceIndex]

        let updatedTask = tasks[sourceIndex]
        let totalCount = tasks.count

        view?.updateTask(updatedTask, at: filteredIndex, totalCount: totalCount)
        persistTasks()
    }

    func didDeleteTask(at index: Int) {
        guard index >= 0, index < filteredTasks.count else { return }

        let selectedTaskID = filteredTasks[index].id

        guard let sourceIndex = tasks.firstIndex(where: { $0.id == selectedTaskID }) else { return }

        tasks.remove(at: sourceIndex)
        persistTasks()
        applySearchAndReload()
    }

    func didSearch(text: String) {
        currentSearchText = text
        applySearchAndReload()
    }
}

// MARK: - Private
private extension TasksListPresenter {

    func loadTasks() {
        storageService.fetchTasks { [weak self] storedTasks in
            guard let self else { return }

            if !storedTasks.isEmpty {
                self.tasks = storedTasks
                self.applySearchAndReload()
                return
            }

            if self.storageService.isInitialImportCompleted() {
                self.tasks = []
                self.applySearchAndReload()
                return
            }

            self.loadTasksFromNetwork()
        }
    }

    func loadTasksFromNetwork() {
        networkService.fetchTasks { [weak self] apiTasks in
            guard let self else { return }

            if apiTasks.isEmpty {
                self.handleInitialImportFailure()
            } else {
                self.handleInitialImportSuccess(apiTasks)
            }
        }
    }

    func handleInitialImportSuccess(_ apiTasks: [APITask]) {
        workQueue.async { [weak self] in
            guard let self else { return }

            let mappedTasks = self.mapTasks(from: apiTasks)

            DispatchQueue.main.async {
                self.tasks = mappedTasks
                self.storageService.setInitialImportCompleted()
                self.persistTasks()
                self.applySearchAndReload()
            }
        }
    }

    func handleInitialImportFailure() {
        workQueue.async { [weak self] in
            guard let self else { return }

            let mockTasks = self.makeMockTasks()

            DispatchQueue.main.async {
                self.tasks = mockTasks
                self.storageService.setInitialImportCompleted()
                self.persistTasks()
                self.applySearchAndReload()
            }
        }
    }

    func saveTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.insert(task, at: 0)
        }

        persistTasks()
        applySearchAndReload()
    }

    func persistTasks() {
        let snapshot = tasks
        storageService.replaceTasks(with: snapshot, completion: nil)
    }

    func applySearchAndReload() {
        let tasksSnapshot = tasks
        let searchText = currentSearchText

        workQueue.async { [weak self] in
            guard let self else { return }

            let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            let filteredTasks: [Task]
            if trimmedText.isEmpty {
                filteredTasks = tasksSnapshot
            } else {
                filteredTasks = tasksSnapshot.filter {
                    $0.title.localizedCaseInsensitiveContains(trimmedText)
                    || $0.taskDescription.localizedCaseInsensitiveContains(trimmedText)
                }
            }

            DispatchQueue.main.async {
                self.filteredTasks = filteredTasks
                self.view?.displayTasks(filteredTasks)
                self.view?.displayTasksCount(tasksSnapshot.count)
            }
        }
    }

    func mapTasks(from apiTasks: [APITask]) -> [Task] {
        apiTasks.enumerated().map { index, apiTask in
            Task(
                id: UUID(),
                serverID: apiTask.id,
                title: makeTitle(from: apiTask.todo),
                taskDescription: apiTask.todo,
                createdAt: makeImportedDate(for: index),
                isCompleted: apiTask.completed
            )
        }
    }

    func makeTitle(from text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.count > 28 else {
            return trimmedText
        }

        let endIndex = trimmedText.index(trimmedText.startIndex, offsetBy: 28)
        return String(trimmedText[..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
    }

    func makeImportedDate(for index: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(-(index * 3600)))
    }

    func makeMockTasks() -> [Task] {
        [
            Task(
                id: UUID(),
                serverID: nil,
                title: "Почитать книгу",
                taskDescription: """
                Составить список необходимых продуктов для ужина. \
                Не забыть проверить, что уже есть в холодильнике.
                """,
                createdAt: makeDate(day: 9, month: 10, year: 2024),
                isCompleted: true
            ),
            Task(
                id: UUID(),
                serverID: nil,
                title: "Уборка в квартире",
                taskDescription: "Провести генеральную уборку в квартире",
                createdAt: makeDate(day: 2, month: 10, year: 2024),
                isCompleted: false
            ),
            Task(
                id: UUID(),
                serverID: nil,
                title: "Заняться спортом",
                taskDescription: """
                Сходить в спортзал или сделать тренировку дома. \
                Не забыть про разминку и растяжку.
                """,
                createdAt: makeDate(day: 2, month: 10, year: 2024),
                isCompleted: false
            ),
            Task(
                id: UUID(),
                serverID: nil,
                title: "Работа над проектом",
                taskDescription: """
                Выделить время для работы над проектом на работе. \
                Сфокусироваться на выполнении важных задач.
                """,
                createdAt: makeDate(day: 9, month: 10, year: 2024),
                isCompleted: true
            ),
            Task(
                id: UUID(),
                serverID: nil,
                title: "Вечерний отдых",
                taskDescription: """
                Найти время для расслабления перед сном: \
                посмотреть фильм или послушать музыку
                """,
                createdAt: makeDate(day: 2, month: 10, year: 2024),
                isCompleted: false
            ),
            Task(
                id: UUID(),
                serverID: nil,
                title: "Зарядка утром",
                taskDescription: """
                Сделать короткую зарядку утром, \
                чтобы взбодриться и начать день активнее
                """,
                createdAt: makeDate(day: 2, month: 10, year: 2024),
                isCompleted: false
            ),
            Task(
                id: UUID(),
                serverID: nil,
                title: "Купить продукты",
                taskDescription: "Купить овощи, молоко, яйца и хлеб",
                createdAt: makeDate(day: 3, month: 10, year: 2024),
                isCompleted: false
            )
        ]
    }

    func makeDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year

        return Calendar.current.date(from: components) ?? Date()
    }
}
