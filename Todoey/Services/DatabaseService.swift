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
    static let shared = DatabaseService()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var dbContext: NSManagedObjectContext {
        return self.context
    }
    
    private init() {}
    
    func updateDataInDB() {
        self.saveDataToDB()
    }
    
    func deleteTodoFromDB(todo: Todo) {
        self.context.delete(todo)
        self.saveDataToDB()
    }
    
    func saveDataToDB() {
        do {
            try context.save()
        }catch {
            print(error)
        }
    }
    
    func fetchDataAgaistTitle(title: String) -> [Todo]?{
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
        request.predicate = predicate
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let todos: [Todo] = try self.context.fetch(request)
            return todos
        }catch {
            print(error)
        }
        return nil
    }
    
    func fetchAllDataFromDB() -> [Todo]? {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        do {
            let data: [Todo] = try self.context.fetch(request)
            return data
        }catch {
            print(error)
        }
        return nil
    }
}
