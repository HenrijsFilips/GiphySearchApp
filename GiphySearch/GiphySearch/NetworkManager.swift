//
//  NetworkManager.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 25/07/2024.
//

import Foundation

class NetworkManager: ObservableObject {
    @Published var gifs: [Gif] = []
    @Published var searchPerformed  = false

    private let apiKey = "" 
    private let baseURL = "https://api.giphy.com/v1/gifs/search"
    private var offset = 0

    func fetchGifs(searchQuery: String) {
        offset = 0
        let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)?q=\(query)&api_key=\(apiKey)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            if let decodedResponse = try? JSONDecoder().decode(GiphyResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.gifs = decodedResponse.data
                    self.searchPerformed = true
                }
            } else {
                print("Decoding error")
            }
        }.resume()
    }

    func fetchMoreGifs(searchQuery: String) {
        offset += 12
        let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)?q=\(query)&api_key=\(apiKey)&offset=\(offset)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            if let decodedResponse = try? JSONDecoder().decode(GiphyResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.gifs += decodedResponse.data
                }
            } else {
                print("Decoding error")
            }
        }.resume()
    }
}
