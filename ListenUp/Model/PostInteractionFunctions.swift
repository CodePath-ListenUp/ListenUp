//
//  PostInteractionFunctions.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/27/22.
//

import Foundation

// MARK: Sort
enum SortOrder: String, CaseIterable {
    case score = "Highest Score"
    case downvotes = "Most Downvotes"
    case recent = "Most Recent"
    case oldest = "Oldest"
}

var sortOrder: SortOrder { UserDefaults.standard.preferredSortOrder() }

// Let's make UserDefaults functions to set our SortOrder
extension UserDefaults {
    func setPreferredSortOrder(_ newSort: SortOrder) {
        UserDefaults.standard.set(newSort.rawValue, forKey: "preferredSortOrder")
        print("Just set ")
    }
    func preferredSortOrder() -> SortOrder {
        if let str = UserDefaults.standard.string(forKey: "preferredSortOrder") {
            guard let sort = SortOrder(rawValue: str) else {
                print("\(str) is not a sortOrder... Did someone write to this Default manually?")
                return .score
            }
            return sort
        }
        else {
            return .score
        }
        
    }
}

// MARK: upvote, downvote, heart interactions
func upvotePost(post: Post) -> Bool {
    guard let user = User.current() else {
        print("User is not signed in, can't vote")
        return false
    }
    
    print("user upvoted \(post.trackName)")
    // Check if user has upvoted this post already
    if post.isContainedIn(arr: user.upvotedPosts) {
        post.upvoteCount -= 1
        user.upvotedPosts.removeAll { inPost in
            inPost.objectId == post.objectId
        }
        post.saveEventually()
        user.saveEventually()
        return false
    }
    else {
        // Check if user has the post downvoted
        if post.isContainedIn(arr: user.downvotedPosts) {
            // Remove downvote before continuing
            post.downvoteCount -= 1
            user.downvotedPosts.removeAll { inPost in
                inPost.objectId == post.objectId
            }
            post.saveEventually()
            user.saveEventually()
        }
        // Proceed to add upvote
        post.upvoteCount += 1
        user.upvotedPosts.append(post)
        post.saveEventually()
        user.saveEventually()
        return true
    }
}
func heartPost(post: Post) -> Bool {
    guard let user = User.current() else {
        print("User is not signed in, can't favorite")
        return false
    }
    if post.isContainedIn(arr: user.favoritedPosts) {
        // user has this post as a favorite already
        user.favoritedPosts.removeAll { inPost in
            post.objectId == inPost.objectId
        }
        user.saveEventually()
        return false
    }
    else {
        // user does not have this post as a favorite yet
        user.favoritedPosts.append(post)
        user.saveEventually()
        return true
    }
}
func downvotePost(post: Post) -> Bool {
    guard let user = User.current() else {
        print("User is not signed in, can't vote")
        return false
    }
    
    // Check if user has downvoted this post already
    if post.isContainedIn(arr: user.downvotedPosts) {
        post.downvoteCount -= 1
        user.downvotedPosts.removeAll { inPost in
            inPost.objectId == post.objectId
        }
        post.saveEventually()
        user.saveEventually()
        return false
    }
    else {
        // Check if user has the post upvoted
        if post.isContainedIn(arr: user.upvotedPosts) {
            // Remove upvote before continuing
            post.upvoteCount -= 1
            user.upvotedPosts.removeAll { inPost in
                inPost.objectId == post.objectId
            }
            post.saveEventually()
            user.saveEventually()
        }
        // Proceed to add downvote
        post.downvoteCount += 1
        user.downvotedPosts.append(post)
        post.saveEventually()
        user.saveEventually()
        return true
    }
}
