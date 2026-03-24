//
//  CoreDataManager.swift
//  EMTasks
//
//  Created by Евгений Лукин on 22.03.2026.
//

import CoreData
import Foundation

final class CoreDataManager {

    // MARK: - Properties
    static let shared = CoreDataManager()

    private let persistentContainer: NSPersistentContainer

    // MARK: - Initialization
    private init() {
        let model = Self.makeManagedObjectModel()
        persistentContainer = NSPersistentContainer(
            name: "EMTasksModel",
            managedObjectModel: model
        )

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent stores: \(error)")
            }
        }

        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Public Methods
    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: Self.entityName)
            request.sortDescriptors = [
                NSSortDescriptor(key: "sortIndex", ascending: true)
            ]

            do {
                let objects: [NSManagedObject] = try context.fetch(request)

                let tasks: [Task] = objects.compactMap { object in
                    guard
                        let id = object.value(forKey: "id") as? UUID,
                        let title = object.value(forKey: "title") as? String,
                        let taskDescription = object.value(forKey: "taskDescription") as? String,
                        let createdAt = object.value(forKey: "createdAt") as? Date
                    else {
                        return nil
                    }

                    let serverIDValue = object.value(forKey: "serverID") as? Int64 ?? -1
                    let serverID: Int? = serverIDValue >= 0 ? Int(serverIDValue) : nil

                    let isCompleted = object.value(forKey: "isCompleted") as? Bool ?? false

                    return Task(
                        id: id,
                        serverID: serverID,
                        title: title,
                        taskDescription: taskDescription,
                        createdAt: createdAt,
                        isCompleted: isCompleted
                    )
                }

                completion(tasks)
            } catch {
                assertionFailure("Failed to fetch tasks: \(error)")
                completion([])
            }
        }
    }

    func replaceTasks(with tasks: [Task], completion: (() -> Void)? = nil) {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)

                for (index, task) in tasks.enumerated() {
                    let object = NSEntityDescription.insertNewObject(
                        forEntityName: Self.entityName,
                        into: context
                    )

                    object.setValue(task.id, forKey: "id")
                    object.setValue(Int64(task.serverID ?? -1), forKey: "serverID")
                    object.setValue(task.title, forKey: "title")
                    object.setValue(task.taskDescription, forKey: "taskDescription")
                    object.setValue(task.createdAt, forKey: "createdAt")
                    object.setValue(task.isCompleted, forKey: "isCompleted")
                    object.setValue(Int64(index), forKey: "sortIndex")
                }

                if context.hasChanges {
                    try context.save()
                }

                completion?()
            } catch {
                assertionFailure("Failed to replace tasks: \(error)")
                completion?()
            }
        }
    }
}

// MARK: - Private
private extension CoreDataManager {

    static let entityName = "CDTask"

    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = entityName
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let serverIDAttribute = NSAttributeDescription()
        serverIDAttribute.name = "serverID"
        serverIDAttribute.attributeType = .integer64AttributeType
        serverIDAttribute.isOptional = false
        serverIDAttribute.defaultValue = -1

        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false
        titleAttribute.defaultValue = ""

        let descriptionAttribute = NSAttributeDescription()
        descriptionAttribute.name = "taskDescription"
        descriptionAttribute.attributeType = .stringAttributeType
        descriptionAttribute.isOptional = false
        descriptionAttribute.defaultValue = ""

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        let isCompletedAttribute = NSAttributeDescription()
        isCompletedAttribute.name = "isCompleted"
        isCompletedAttribute.attributeType = .booleanAttributeType
        isCompletedAttribute.isOptional = false
        isCompletedAttribute.defaultValue = false

        let sortIndexAttribute = NSAttributeDescription()
        sortIndexAttribute.name = "sortIndex"
        sortIndexAttribute.attributeType = .integer64AttributeType
        sortIndexAttribute.isOptional = false
        sortIndexAttribute.defaultValue = 0

        entity.properties = [
            idAttribute,
            serverIDAttribute,
            titleAttribute,
            descriptionAttribute,
            createdAtAttribute,
            isCompletedAttribute,
            sortIndexAttribute
        ]

        model.entities = [entity]

        return model
    }
}
