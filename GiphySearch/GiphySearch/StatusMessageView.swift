//
//  StatusMessageView.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 25/07/2024.
//


import SwiftUI

struct StatusMessageView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .padding()
    }
}
