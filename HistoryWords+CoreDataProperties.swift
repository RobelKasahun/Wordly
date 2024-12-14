//
//  HistoryWords+CoreDataProperties.swift
//  wordly
//
//
//

import Foundation
import CoreData


extension HistoryWords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryWords> {
        return NSFetchRequest<HistoryWords>(entityName: "HistoryWords")
    }

    @NSManaged public var word: String?

}

extension HistoryWords : Identifiable {

}
