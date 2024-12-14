//
//  SearchViewModel.swift
//  wordly
//
//

import Foundation
struct APIError: Codable {
    var title: String
    var message: String
}

class SearchViewModel: ObservableObject {
    @Published var searchResponseModel: [SearchResponseModel] = []
    @Published var errorMessage: String?
    @Published var apiError: APIError? // To store the error details
    
    func fetchWordDetails(for searchText: String) {
        guard let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(encodedSearchText)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([SearchResponseModel].self, from: data)
                DispatchQueue.main.async {
                    self?.errorMessage = nil
                    self?.searchResponseModel = decodedResponse
                    self?.apiError = nil
                    
                }
            } catch {
                do {
                    let apiError = try JSONDecoder().decode(APIError.self, from: data)
                    DispatchQueue.main.async {
                        self?.apiError = apiError // Set the API error
                        self?.searchResponseModel = [] // Clear any previous results
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
        
        
    }
    
}


