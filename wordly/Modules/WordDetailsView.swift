//
//  WordDetailsView.swift
//  wordly
//
//

import SwiftUI
import CoreData
import AVKit

struct WordDetailsView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = SearchViewModel()
    @Binding var searchText: String?
    @State private var audioPlayer: AVPlayer?
    @State private var favorites: Set<String> = [] // <-- Track favorites here
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Details")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.forward")
                        .resizable()
                        .frame(width: 25, height: 20)
                        .foregroundColor(.black)
                }
                .padding(20)
            }
            
            if viewModel.searchResponseModel.isEmpty {
                if let apiError = viewModel.apiError {
                    Text(apiError.title)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Text(apiError.message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding()
                } else {
                    Text("No results found")
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }else {
                List(Array(viewModel.searchResponseModel.enumerated()), id: \.offset) { index, wordData in
                    Section(header: HStack {
                        Text(wordData.word.capitalized)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        if index == 0 {
                            Button(action: {
                                toggleFavorite(for: wordData.word)
                            }) {
                                Image(systemName: isFavorite(word: wordData.word) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                        }
                        
                    }) {
                        ForEach(wordData.phonetics.filter { !($0.audio?.isEmpty ?? true) }, id: \.audio) { phonetic in
                            HStack {
                                Text((phonetic.text?.isEmpty ?? true) ? wordData.word : phonetic.text!)
                                    .foregroundColor(.black)
                                
                                if let audioURL = phonetic.audio, let url = URL(string: audioURL) {
                                    Spacer()
                                    Button(action: {
                                        playAudio(url: url)
                                    }) {
                                        Image(systemName: "play.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                }
                            }
                        }
                        
                        ForEach(wordData.meanings, id: \.partOfSpeech) { meaning in
                            Section(header: Text(meaning.partOfSpeech.capitalized)) {
                                ForEach(meaning.definitions, id: \.definition) { definition in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(definition.definition)
                                            .padding(.bottom, 5)
                                        
                                        if let example = definition.example {
                                            Text("Example: \(example)")
                                                .italic()
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

            }
            
            Spacer()
        } 
        .onAppear {
            viewModel.fetchWordDetails(for: searchText ?? "")
            checkIfFavorite(for: searchText ?? "")
        }
        
        
        
        
        if let errorMessage = viewModel.errorMessage {
            Text("Error: \(errorMessage)")
                .foregroundColor(.red)
                .padding()
        }
        
        
        
    }
    
    func isFavorite(word: String) -> Bool {
        return favorites.contains(word)
    }
    
    // Toggle favorite status for the word
    func toggleFavorite(for word: String) {
        if isFavorite(word: word) {
            favorites.remove(word)
            CoreDataManager.shared.deleteFavoriteWord(word: word)
        } else {
            favorites.insert(word)
            CoreDataManager.shared.saveToFavorites(word: word)
        }
    }
    
    func checkIfFavorite(for word: String) {
        let favoriteWords = CoreDataManager.shared.fetchFavoriteWords()
        favorites = Set(favoriteWords)
    }
    
    private func playAudio(url: URL) {
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
    }
    
    
}
