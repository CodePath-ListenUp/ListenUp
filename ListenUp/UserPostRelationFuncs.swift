//
//  UserPostRelationFuncs.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/20/22.
//

import Foundation
import Parse

extension Post {
    func isContainedIn(arr: [Post]) -> Bool {
        arr.contains(where: { post in
            post.objectId == self.objectId
        })
    }
}
