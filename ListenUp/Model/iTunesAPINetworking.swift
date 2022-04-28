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
    let trackId: Int
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
//    print(combinedEndpoint)
    
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

class Post: PFObject, PFSubclassing, Codable {
    static func parseClassName() -> String {
        return "Post"; 
    }
    
    override init() {
        super.init()
    }
    
    
    
    internal init(song: SongResult, createdBy: User, completion: ((Post)->())?) {
        super.init()

        self.postId = UUID().hashValue
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

        // URL template:
        //https://is4-ssl.mzstatic.com/image/thumb/Music114/v4/ce/c7/96/cec796f8-9521-b1f0-7300-17c710d35242/source/100x100bb.jpg

        self.artworkUrl750 = song.artworkUrl100.replacingOccurrences(of: "100x100bb.jpg", with: "750x750bb.jpg")

        self.artworkUrl100 = song.artworkUrl100


        self.trackViewUrl = song.trackViewUrl
        self.releaseDate = song.releaseDate
        self.primaryGenreName = song.primaryGenreName

        // This is a neat technique to make our viewDidLoad wait until the songwhip link is grabbed before sending the post to Parse
        getSongwhipFromLink(linkString: song.trackViewUrl, completion: { result in
            self.songLinkString = result.url
            if let completionFunc = completion {
                completionFunc(self)
            }
        })
        
    }
    
    @NSManaged var postId: Int
    
    @NSManaged var songLinkString: String?
    @NSManaged var upvoteCount: Int
    @NSManaged var downvoteCount: Int
    var calculatedScore: Int {
        upvoteCount - downvoteCount
    }
    @NSManaged var createdBy: User
    
    @NSManaged var trackName: String
    @NSManaged var artistName: String
    @NSManaged var collectionName : String
    @NSManaged var trackCensoredName : String
    @NSManaged var collectionCensoredName : String
    @NSManaged var previewUrl : String
    @NSManaged var artworkUrl100 : String
    @NSManaged var artworkUrl750 : String
    @NSManaged var trackViewUrl: String
    @NSManaged var releaseDate : String
    @NSManaged var primaryGenreName : String
}

class User: PFUser, Codable {
    internal override init() {
        super.init()
    }
    
    @NSManaged var submittedPosts: [Post]
    @NSManaged var upvotedPosts: [Post]
    @NSManaged var favoritedPosts: [Post]
    @NSManaged var downvotedPosts: [Post]
}
