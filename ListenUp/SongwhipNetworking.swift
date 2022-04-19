//
//  SongwhipNetworking.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/14/22.
//

import Foundation

func getSongwhipFromLink(linkString: String, completion: @escaping (SongwhipResult) -> ()) {
    let url = URL(string: "https://songwhip.com")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let str = "{\"url\":\"\(linkString)\"}"
    request.httpBody = Data(str.utf8)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        else if let data = data {
            if let decoded = try? JSONDecoder().decode(SongwhipResult.self, from: data) {
                completion(decoded)
            }
            else {
                print("Couldn't decode Songwhip result: \(String(data: data, encoding: .utf8) ?? "Unknown")")
            }
        }
        else {
            print("oh that's weird")
        }
    }.resume()
}

struct SongwhipResult: Codable {
    let url: String
}
