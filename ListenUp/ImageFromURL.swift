//
//  ImageFromURL.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/14/22.
//

import Foundation
import UIKit

// These are a couple of useful image functions I have in my toolbox ;)

func getImage(from url: URL) -> UIImage? {
    var returning: UIImage? = nil
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
            let data = data, error == nil,
            let image = UIImage(data: data)
        else { return }
        returning = image
    }.resume()
    while (returning == nil) {
    }
    
    return returning
}

func getImage(from link: String) -> UIImage? {
    guard let url = URL(string: link) else { return nil }
    return getImage(from: url)
}

//If you're using an imageView, use this UIImageView extension instead!
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
