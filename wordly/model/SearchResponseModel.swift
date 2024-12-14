//
//  SearchResponseModel.swift
//  wordly
//
//

import Foundation

struct SearchResponseModel: Codable {
    var word: String
    var phonetics: [Phonetic]
    var meanings: [Meaning]
}

struct Phonetic: Codable {
    var text: String?
    var audio: String?
    var sourceUrl: String?
}

struct Meaning: Codable, Identifiable {
    var id: String {
          return "\(partOfSpeech)-\(definitions.first?.definition ?? "")"
      }
    
    var partOfSpeech: String
    var definitions: [Definition]
}

struct Definition: Codable {
    var definition: String
    var example: String?
}

