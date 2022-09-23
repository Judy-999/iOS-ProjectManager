//
//  CoreDataManager.swift
//  ProjectManager
//
//  Created by Judy on 2022/09/22.
//

import RxSwift
import CoreData
import Foundation

class CoreDataManager: DatabaseManageable {
    static let shared = CoreDataManager()
    
    private init() { }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProjectManager")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveWork(_ work: Work) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WorkEntity")
        fetchRequest.predicate = NSPredicate(format: "id = %@", work.id as CVarArg)
        
        let saveEntity: [String: Any] = [
            "id": work.id,
            "title": work.title,
            "content": work.content,
            "deadline": work.deadline,
            "state": work.state.rawValue
        ]
        
        do {
            guard let updateObject = try context.fetch(fetchRequest).first as? NSManagedObject else {
                let newEntity = NSEntityDescription.insertNewObject(forEntityName: "WorkEntity", into: context)
                newEntity.setValuesForKeys(saveEntity)
                return
            }
            
            updateObject.setValuesForKeys(saveEntity)
        } catch {
            print(error.localizedDescription)
        }
        
        saveContext()
    }
    
    func deleteWork(id: UUID) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WorkEntity")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        
        do {
            guard let deleteObject = try context.fetch(fetchRequest).first as? NSManagedObject else { return }
            context.delete(deleteObject)
        } catch {
            print(error.localizedDescription)
        }
        
        saveContext()
    }
    
    func fetchWork() -> Observable<[Work]> {
        let context = persistentContainer.viewContext
        
        do {
            let workEntities = try context.fetch(WorkEntity.fetchRequest())
            
            return Observable.just(
                workEntities.compactMap {
                    guard let state = WorkState(rawValue: $0.state) else { return nil }
                    return Work(id: $0.id, title: $0.title, content: $0.content, deadline: $0.deadline, state: state)
                }
            )
        } catch {
            print(error.localizedDescription)
        }
        
        return Observable.error(NSError(domain: "fetch failed", code: 111))
    }
}