//
//  ContentView.swift
//  GiphySearch
//
//  Created by Henrijs Filips Verlis on 17/07/2024.
//

import SwiftUI
import Foundation

// the main view
struct ContentView: View {
    @StateObject private var networkManager = NetworkManager() //manages network calls and stores data about gifs
    @State private var searchText = "" //holds the current search query
    @State private var lastGifId: String? //tracks the id of the last gif for pagination

    var body: some View {
        Spacer()
        VStack {
            Text("Search For Giphs")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding()
        
            //text field
            TextField("Search..", text: $searchText, onCommit: {
                networkManager.fetchGifs(searchQuery: searchText) //fetch gifs when the user presses return
            })
                .padding()
                .textFieldStyle(.roundedBorder)

            //shows this to direct user on what to do. acts like a status bar
            if !networkManager.searchPerformed {
                Text("Enter a query to search for gifs")
                    .font(.subheadline)
            }
            //if the gif array is empty but a search is performed show that no results are found
            else if networkManager.gifs.isEmpty && networkManager.searchPerformed {
                Text("No results found")
                    .padding()
            }
            //display the gifs in a grid
            else {
                ScrollView {
                    ScrollViewReader { scrollView in
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) { //3 columns grid
                            ForEach(networkManager.gifs) { gif in
                                GifView(gif: gif) //custom view for each gif
                                    .onAppear {
                                        //fetch more gifs when the last gif appears
                                        if gif.id == lastGifId {
                                            networkManager.fetchMoreGifs(searchQuery: searchText)
                                        }
                                    }
                            }
                        }
                        //update the last gif id when new gifs are loaded
                        .onChange(of: networkManager.gifs) { gifs, _ in
                            lastGifId = gifs.last?.id
                        }
                    }
                }
            }
            //show the "Clear Search" button after a search has been performed
            if networkManager.searchPerformed {
                Button(action: {
                    //clear search results and reset states with animation. dispatchqueue for the 0.3 delay before the animation starts
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring){
                            searchText = ""
                            networkManager.gifs = []
                            networkManager.searchPerformed = false
                        }
                    }
                }) {
                    Text("Clear Search") //button label
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

//custom view for displaying a single gif
struct GifView: View {
    let gif: Gif //gif object to display
    
    var body: some View {
        VStack {
            //load and display the gif image from url
            if let url = URL(string: gif.images.original.url) {
                AsyncImage(url: url)
                    .frame(width: 100, height: 100) //fixed size for the image
                    .clipped() //clip the image to the frame
            }
            //the title of the gif
            Text(gif.title)
                .font(.caption)
                .lineLimit(1)
        }
    }
}

//network manager class for handling api requests and storing data
class NetworkManager: ObservableObject {
    @Published var gifs: [Gif] = [] //array that stores fetched gifs
    @Published var searchPerformed  = false //flag to indicate if a search has been performed

    private let apiKey = "" //giphy search api key
    private let baseURL = "https://api.giphy.com/v1/gifs/search" //base url for the giphy search api
    private var offset = 0 //offset for pagination

    //function to fetch gifs based on the search query
    func fetchGifs(searchQuery: String) {
        offset = 0 //reset offset for new search
        let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" //encode the search query
        //construct the url for the api request
        guard let url = URL(string: "\(baseURL)?q=\(query)&api_key=\(apiKey)") else {
            print("Invalid URL") //print error if url is invalid
            return
        }

        //performs the api request
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)") //prints error if request fails
                return
            }

            guard let data = data else {
                print("No data") //print error if no data is returned
                return
            }

            //decode the json response
            if let decodedResponse = try? JSONDecoder().decode(GiphyResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.gifs = decodedResponse.data //update the gifs array
                    self.searchPerformed = true //set searchPerformed to true
                }
            } else {
                print("Decoding error") //print error if the decoding fails
            }
        }.resume() //this tells the task to start running and begin the network request
    }
    
    //function to fetch more gifs for pagination/scrolling view
    func fetchMoreGifs(searchQuery: String) {
        offset += 12 //increment the offset
        let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" //encode the search query
        
        //eonstruct the url for the api request with offset
        guard let url = URL(string: "\(baseURL)?q=\(query)&api_key=\(apiKey)&offset=\(offset)") else {
            print("Invalid URL") //print error if url is invalid
            return
        }
        
        //perform the api request without recieving response
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)") //print error if request fails
                return
            }
            
            guard let data = data else {
                print("No data") //print error if no data is returned
                return
            }
            
            // Decode the JSON response
            if let decodedResponse = try? JSONDecoder().decode(GiphyResponse.self, from: data) {
               DispatchQueue.main.async {
                   self.gifs += decodedResponse.data //append new gifs to the array
               }
           } else {
               print("Decoding error") //print error if decoding fails
           }
       }.resume() //start the data task
    }
}

//response structure for the giphy api
struct GiphyResponse: Codable {
    let data: [Gif] //array of gif objects
}

//structure for a single gif object
struct Gif: Codable, Identifiable, Equatable {
    let id: String //id of the gif
    let title: String //title of the gif
    let images: Images //images object containing urls

    //structure for the images object
    struct Images: Codable, Equatable {
        let original: Original //original image url object

        //structure for the original image url object
        struct Original: Codable, Equatable {
            let url: String //url of the original image
        }
    }
}
