//
//  iTunesAPINetworking.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/13/22.
//

import Foundation
import Parse
import UIKit

struct iTunesAPIResponse: Codable {
    let resultCount: Int
    let results: [SongResult]
}

struct SongResult: Codable {
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
    
    // Unused atm
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

// Idk if this will stay here but I need to make it somewhere
class Post: PFObject, PFSubclassing, Codable {
    static func parseClassName() -> String {
        "Post"
    }
    
    internal init(song: SongResult, createdBy: User, completion: ((Post)->())?) {
        self.id = UUID().hashValue
        self.upvoteCount = 0
        self.downvoteCount = 0
        self.createdBy = createdBy
        
        // Below are all the properties that get copied over from the SongResult that iTunes gives.
        
        
        self.trackName = song.trackName
        self.artistName = song.artistName
        self.collectionName = song.collectionName
        self.trackCensoredName = song.trackCensoredName
        self.collectionCensoredName = song.collectionCensoredName
        self.previewUrl = song.previewUrl
        self.artworkUrl100 = song.artworkUrl100
        self.trackViewUrl = song.trackViewUrl
        self.releaseDate = song.releaseDate
        self.primaryGenreName = song.primaryGenreName
        
        super.init()
        
        // This is a neat technique to make our viewDidLoad wait until the songwhip link is grabbed before sending the post to Parse
        getSongwhipFromLink(linkString: song.trackViewUrl, completion: { result in
            self.songLinkString = result.url
            if let completionFunc = completion {
                completionFunc(self)
            }
        })
        
    }
    
    var id: Int
    
    var songLinkString: String? = nil
    var upvoteCount: Int
    var downvoteCount: Int
    var calculatedScore: Int {
        upvoteCount - downvoteCount
    }
    let createdBy: User
    
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
}

class User: PFUser, Codable {
    internal override init() {
        super.init()
    }
    
    var submittedPosts: [Post] = []
    var upvotedPosts: [Post] = []
    var favoritedPosts: [Post] = []
    var downvotedPosts: [Post] = []
}
