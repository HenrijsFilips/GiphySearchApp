//
//  SearchBarView.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 25/07/2024.
//


import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSearch: () -> Void

    var body: some View {
        TextField("Search..", text: $searchText, onCommit: onSearch)
            .padding()
            .textFieldStyle(.roundedBorder)
    }
}
