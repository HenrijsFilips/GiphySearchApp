//
//  GifGridView.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 25/07/2024.
//


import SwiftUI

struct GifGridView: View {
    let gifs: [Gif]
    @Binding var lastGifId: String?
    @Binding var searchText: String
    @ObservedObject var networkManager: NetworkManager

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(gifs) { gif in
                        GifView(gif: gif)
                            .onAppear {
                                if gif.id == lastGifId {
                                    networkManager.fetchMoreGifs(searchQuery: searchText)
                                }
                            }
                    }
                }
                .onChange(of: gifs) { gifs, _ in
                    lastGifId = gifs.last?.id
                }
            }
        }
    }
}
