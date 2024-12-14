//
//  FavoriteListView.swift
//  wordly
//

import SwiftUI
import CoreData

struct FavoriteListView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var favorites: [String] = []
    @State private var navigateToDetails = false
    @State private var selectedWord: String? // To store the selected word

    var body: some View {
        VStack {
            HStack {
                Text("Favorite Words")
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
            
            Spacer()
            
            if favorites.isEmpty {
                Text("No favorite words added.")
                    .foregroundColor(.gray)
                    .padding()
                
                Spacer()
            } else {
                List(favorites, id: \.self) { word in
                    HStack {
                        Text(word)
                        
                        Spacer()
                        
                        Button(action: {
                            deleteFavorite(word: word)
                        }) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedWord = word
                        navigateToDetails = true
                    }
                    .clipped()

                }
                .onAppear {
                    fetchFavouriteList()
                }
            }
        }
        .navigationBarTitle("Favorites", displayMode: .inline)
        .navigate(to: WordDetailsView(searchText: $selectedWord), when: $navigateToDetails)
        .onAppear {
            fetchFavouriteList()
        }
        .onDisappear {
            navigateToDetails = false
        }
    }
    
    func fetchFavouriteList() {
        let favoriteWords = CoreDataManager.shared.fetchFavoriteWords()
        favorites = favoriteWords
    }
    
    func deleteFavorite(word: String) {
        if let index = favorites.firstIndex(of: word) {
            favorites.remove(at: index)
        }
        
        CoreDataManager.shared.deleteFavoriteWord(word: word)
        
        fetchFavouriteList()
    }
}

#Preview {
    FavoriteListView()
}
