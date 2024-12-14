//
//  FavoriteWords+CoreDataProperties.swift
//  wordly
//
//
//

import Foundation
import CoreData


extension FavoriteWords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteWords> {
        return NSFetchRequest<FavoriteWords>(entityName: "FavoriteWords")
    }

    @NSManaged public var word: String?

}

extension FavoriteWords : Identifiable {

}
