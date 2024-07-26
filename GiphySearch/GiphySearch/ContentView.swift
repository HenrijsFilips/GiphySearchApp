//
//  ContentView.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 17/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var searchText = ""
    @State private var lastGifId: String?

    var body: some View {
        Spacer()
        VStack {
            Text("Search For Giphy")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding()

            SearchBarView(searchText: $searchText, onSearch: {
                networkManager.fetchGifs(searchQuery: searchText)
            })

            if !networkManager.searchPerformed {
                StatusMessageView(message: "Enter a query to search for gifs")
            } else if networkManager.gifs.isEmpty {
                StatusMessageView(message: "No results found")
            } else {
                GifGridView(gifs: networkManager.gifs, lastGifId: $lastGifId, searchText: $searchText, networkManager: networkManager)
            }

            if networkManager.searchPerformed {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring) {
                            searchText = ""
                            networkManager.gifs = []
                            networkManager.searchPerformed = false
                        }
                    }
                }) {
                    Text("Clear Search")
                }
                .buttonBorderShape(.roundedRectangle(radius: 20))
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .padding()
        Spacer()
        Spacer()
        Spacer()
    }
}

#Preview {
    ContentView()
}
