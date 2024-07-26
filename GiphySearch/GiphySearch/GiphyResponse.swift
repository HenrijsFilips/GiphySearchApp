//
//  GiphyResponse.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 25/07/2024.
//


import Foundation

struct GiphyResponse: Codable {
    let data: [Gif]
}

struct Gif: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let images: Images

    struct Images: Codable, Equatable {
        let original: Original

        struct Original: Codable, Equatable {
            let url: String
        }
    }
}
