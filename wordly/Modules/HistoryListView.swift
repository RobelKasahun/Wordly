//
//  HistoryListView.swift
//  wordly
//
//


import SwiftUI
import CoreData

struct HistoryListView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var history: [String] = []
    @State private var navigateToDetails = false
    @State private var selectedWord: String?

    var body: some View {
        VStack {
            HStack {
                Text("History Words")
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
            
            if history.isEmpty {
                Text("No history words added.")
                    .foregroundColor(.gray)
                    .padding()
                
                Spacer()
            } else {
                List(history, id: \.self) { word in
                    HStack {
                        Text(word)
                        
                        Spacer()
                       
                        Button(action: {
                            deleteHistory(word: word)
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.black)
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
                    fetchHistoryList()
                }
            }
        }
        .navigationBarTitle("History", displayMode: .inline)
        .navigate(to: WordDetailsView(searchText: $selectedWord), when: $navigateToDetails)
        .onAppear {
            fetchHistoryList()
        }
        .onDisappear {
            navigateToDetails = false
        }
    }
    
    func fetchHistoryList() {
        let historyWords = CoreDataManager.shared.fetchHistoryWords()
        history = historyWords.reversed()
    }
    
    func deleteHistory(word: String) {
        if let index = history.firstIndex(of: word) {
            history.remove(at: index)
        }
        
        CoreDataManager.shared.deleteHistoryWord(word: word)
        
        fetchHistoryList()
    }
}
