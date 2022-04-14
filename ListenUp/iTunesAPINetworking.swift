//
//  iTunesAPINetworking.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/13/22.
//

import Foundation
import UIKit

struct iTunesAPIResponse: Codable {
    let resultCount: Int
    let results: [SongResult]
}

struct SongResult: Codable {
    internal init(trackName: String, artistName: String, collectionName: String, trackCensoredName: String, collectionCensoredName: String, previewUrl: String, artworkUrl100: String, releaseDate: String, primaryGenreName: String, trackViewUrl: String) {
        self.trackName = trackName
        self.artistName = artistName
        self.collectionName = collectionName
        self.trackCensoredName = trackCensoredName
        self.collectionCensoredName = collectionCensoredName
        self.previewUrl = previewUrl
        self.artworkUrl100 = artworkUrl100
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.trackViewUrl = trackViewUrl
        
//        guard let artworkURL = URL(string: artworkUrl100) else {
//            return
//        }
//        
//        self.artworkImageData = getImage(from: artworkURL)?.pngData()
    }
    
    let trackName: String
    let artistName: String
    let collectionName : String
    let trackCensoredName : String
    let collectionCensoredName : String
    let previewUrl : String
    let artworkUrl100 : String
    let trackViewUrl: String
    let releaseDate : String
    let primaryGenreName : String
    
    var artworkImageData: Data?
}

func retrieveITUNESResults(rawSearchTerm: String, completion: @escaping ([SongResult]) -> ()) {
    let iTunesEndpoint: URL = URL(string: "https://itunes.apple.com/search")!
    
    let convertedSearchTerm = rawSearchTerm.replacingOccurrences(of: " ", with: "%20")
    let entity = "song"
    
    guard let combinedEndpoint = URL(string: "\(iTunesEndpoint)?term=\(convertedSearchTerm)&entity=\(entity)") else {
        print("Could not construct endpoint")
        return
    }
    print(combinedEndpoint)
    
    URLSession.shared.dataTask(with: combinedEndpoint) { data, response, error in
        if let error = error {
            print("There was an error!\nDetails: \(error.localizedDescription)")
            return
        }
        else if let data = data {
            if let decoded = try? JSONDecoder().decode(iTunesAPIResponse.self, from: data) {
                completion(decoded.results)
            }
        }
        else {
            print("An unknown error occurred.")
        }
    }.resume()
}
