//
//  GifView.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 25/07/2024.
//

import SwiftUI

struct GifView: View {
    let gif: Gif

    var body: some View {
        VStack {
            if let url = URL(string: gif.images.original.url) {
                AsyncImage(url: url)
                    .frame(width: 100, height: 100)
                    .clipped()
            }
            
            Text(gif.title)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
