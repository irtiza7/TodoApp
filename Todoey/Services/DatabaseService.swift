//
//  DatabaseService.swift
//  Todoey
//
//  Created by Dev on 7/10/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class DatabaseService {
    
    // MARK: - Static Properties
    
    static let shared = DatabaseService()
    
    // MARK: - Private Properties
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Public Properties
    
    public var dbContext: NSManagedObjectContext {
        return self.context
    }
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Methods For Saving Records
    
    public func saveDataToDB() {
        do {
            try context.save()
        }catch {
            print(error)
        }
    }
    
    // MARK: - Methods For Fetching All Records
    
    public func genericFetchAllRecordsFromDB<T: NSManagedObject>(entityName: T.Type) -> [T]? {
        let request = NSFetchRequest<T>(entityName: String(describing: entityName))
        do {
            return try self.context.fetch(request)
        }catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - Methods For Updating Records
    
    public func updateDataInDB() {
        self.saveDataToDB()
    }
    
    // MARK: - Methods For Deleting Records
    
    public func deleteTodoFromDB(todo: Todo) {
        self.context.delete(todo)
        self.saveDataToDB()
    }
    
    public func deleteCategoryFromDB(category: Category) {
        self.context.delete(category)
        self.saveDataToDB()
    }
    
    public func genericDeleteRecordFromDB(record: NSManagedObject) {
        self.context.delete(record)
        self.saveDataToDB()
    }
    
    // MARK: - Methods for Fetching Records
    
    public func genericFetchRecordsAgainstAttributes<T: NSManagedObject>(entityName: T.Type, title: String = "", category: String = "") -> [T]? {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: entityName))
        
        var predicates: [NSPredicate] = []
        if title != "" {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
            predicates.append(predicate)
        }
        if category != "" {
            let predicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", category)
            predicates.append(predicate)
        }
        switch predicates.count {
        case let c where c > 1:
            let compountPredicate: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.predicate = compountPredicate
        case let c where c == 1:
            request.predicate = predicates[0]
        default:
            break
        }
        
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try self.context.fetch(request)
        }catch {
            print(error)
            return nil
        }
    }
}
