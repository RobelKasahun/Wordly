//
//  CoreDataManager.swift
//  wordly
//
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    private let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "wordly")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveToFavorites(word: String) {
        let favoriteWord = FavoriteWords(context: context)
        favoriteWord.word = word
        
        do {
            try context.save()
            print("\(word) saved to favorites.")
        } catch {
            print("Failed to save to Core Data: \(error.localizedDescription)")
        }
    }
    
    func fetchFavoriteWords() -> [String] {
        let fetchRequest: NSFetchRequest<FavoriteWords> = FavoriteWords.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { $0.word }
        } catch {
            print("Failed to fetch favorites: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteFavoriteWord(word: String) {
        let fetchRequest: NSFetchRequest<FavoriteWords> = FavoriteWords.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word == %@", word)
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("\(word) removed from favorites.")
        } catch {
            print("Failed to delete word: \(error.localizedDescription)")
        }
    }
    
    
  //  ------------
    
    func saveToHistoryWords(word: String) {
        deleteHistoryWord(word: word)

        let historyWord = HistoryWords(context: context)
        historyWord.word = word
        
        do {
            try context.save()
            print("\(word) saved to history.")
        } catch {
            print("Failed to save to Core Data: \(error.localizedDescription)")
        }
    }
    
    func fetchHistoryWords() -> [String] {
        let fetchRequest: NSFetchRequest<HistoryWords> = HistoryWords.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { $0.word }
        } catch {
            print("Failed to fetch history: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteHistoryWord(word: String) {
        let fetchRequest: NSFetchRequest<HistoryWords> = HistoryWords.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word == %@", word)
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("\(word) removed from history.")
        } catch {
            print("Failed to delete word: \(error.localizedDescription)")
        }
    }
}
