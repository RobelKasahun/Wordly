//
//  ContentView.swift
//  wordly
//
//

import SwiftUI
import CoreData
import AVKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = SearchViewModel()
    @State var searchText = ""
    @State private var isEditing: Bool = false
    @State private var audioPlayer: AVPlayer?
    @State private var favorites: Set<String> = [] // <-- Track favorites here
    @State private var navigateToFavorites = false
    @State private var navigateToHistory = false

    
    var body: some View {
        VStack {
            HStack {
                Text("Wordly")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        self.navigateToFavorites = true
                    }) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 20,height: 20)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        self.navigateToHistory = true
                    }) {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .resizable()
                            .frame(width: 20,height: 25)
                            .foregroundColor(.black)
                    }
                }
                .padding(20)

            }
            
            
            
            TextField("Search for a word", text: $searchText, onCommit: {
                if !searchText.isEmpty {
                    isEditing = false
                    viewModel.fetchWordDetails(for: searchText)
                    checkIfFavorite(for: searchText)
                    CoreDataManager.shared.saveToHistoryWords(word: searchText)

                }else {
                    isEditing = false
                }
            })
            .onTapGesture {
                isEditing = true
            }
            .onChange(of: searchText) { _ in
                if searchText.isEmpty {
                    isEditing = false
                    viewModel.searchResponseModel = []
                    viewModel.errorMessage = nil
                    viewModel.apiError = nil
                }
            }
            .textFieldStyle(PlainTextFieldStyle())
            .padding(.horizontal, 12)
            .frame(height: 50)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
            
            Spacer()
            
            if !isEditing {
                if searchText.isEmpty {
                    Text("Let's start searching!")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                    
                }else if viewModel.searchResponseModel.isEmpty && !isEditing {
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
                    .onAppear {
                        // **This triggers the favorite checking when the view appears**
                        checkIfFavorite(for: searchText)
                    }
                    
                }
            }
            Spacer()
        }
        .navigate(to: FavoriteListView(), when: $navigateToFavorites)
        .navigate(to: HistoryListView(), when: $navigateToHistory)

        .onDisappear {
            navigateToHistory = false
            navigateToFavorites = false
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

extension View {
 
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
            NavigationView {
                ZStack {
                    self
                        .navigationBarTitle("")
                        .navigationBarHidden(true)

                    NavigationLink(
                        destination: view
                            .navigationBarTitle("")
                            .navigationBarHidden(true),
                        isActive: binding
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    
}
