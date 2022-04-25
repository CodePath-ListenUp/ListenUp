//
//  PostListTemplateController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/20/22.
//

import Foundation
import Parse
import SafariServices
import UIKit
import AVFAudio

protocol PostListDelegate//: UITableViewDelegate, UITableViewDataSource
{
    var posts: [Post] { get }
//    var tableView: UITableView! { get }
    var whatsPlaying: PostTableViewCell? { get }
    
    
}

class ParentPostList: UIViewController, UITableViewDelegate, UITableViewDataSource, PostListDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    
    var posts: [Post] = []
    var whatsPlaying: PostTableViewCell? = nil
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        
        let post = posts[indexPath.row]
        cell.post = post
        cell.albumArtworkView.image = UIImage(named: "default.jpg")!
        cell.trackNameLabel?.text = post.trackName
        cell.artistNameLabel?.text = post.artistName
        
        // Just another implementation for the images that we probably won't use
//        guard let albumArtworkData = post.artworkImageData else {
//            return cell
//        }
//
//        cell.albumArtworkView.image = UIImage(data: albumArtworkData)

        //MARK: Tags for Right-hand controls
        // upvote: 5
        // heart: 6
        // downvote: 7
        //
        // Have to create a unique tapGesture for each element,
        // so I'm using a for loop to expedite that / make it unified
        for view in [cell.upvoteSymbol,cell.heartIcon,cell.downvoteSymbol] {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapElement(_:)))
            tapGesture.numberOfTapsRequired = 1
            view?.addGestureRecognizer(tapGesture)
        }
        
        if let user = User.current() {
            user.fetchIfNeededInBackground { success, error in
                // lol this is kinda backwards but oh well
                guard let error = error else {
                    cell.upvoteSymbol.tintColor = overrideAccentColor(basedOn: post.isContainedIn(arr: user.upvotedPosts), with: upvoteColor)
                    cell.downvoteSymbol.tintColor = overrideAccentColor(basedOn: post.isContainedIn(arr: user.downvotedPosts), with: downvoteColor)
                    cell.updateHeartUI(favoriteStatus: post.isContainedIn(arr: user.favoritedPosts))
                    return
                }
                print("error: \(error.localizedDescription)")
            }
        }
        guard let albumArtworkURL = URL(string: post.artworkUrl100) else {
            return cell
        }
        
        cell.albumArtworkView?.load(url: albumArtworkURL)
        
        // Source: https://stackoverflow.com/a/35019685
        cell.darkeningLayer.frame = cell.albumArtworkView.bounds;
        cell.darkeningLayer.backgroundColor = UIColor.black.cgColor
        cell.darkeningLayer.opacity = nonPlayingArtworkOpacity
        cell.albumArtworkView.layer.addSublayer(cell.darkeningLayer)
        
        //
        // MARK: Media Button Work
        //
        
        // To identify which cell's button got called, we can use tag to pass the indexPath row
        cell.mediaButton.tag = indexPath.row
        
        cell.mediaButton.layer.shadowRadius = 10
        cell.mediaButton.layer.shadowOpacity = 0.8
        
        // To prevent having two Storyboard connections, I'm using the outlet to make an action
        cell.mediaButton.addTarget(self, action: #selector(userPressedMediaButton), for: .touchUpInside)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 92, bottom: 0, right: 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell, let post = cell.post else {
            print("No post could be found for the swiped cell")
            return nil
        }
        
        let downvote = UIContextualAction(style: .normal, title: "Downvote") { action, view, completionHandler in
            let downvoted = self.downvotePost(post: post)
            cell.downvoteSymbol.tintColor = overrideAccentColor(basedOn: downvoted, with: downvoteColor)
            cell.upvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: upvoteColor)
            action.image = UIImage(systemName: downvoted ? "arrow.uturn.backward" : "chevron.down")
            completionHandler(true)
        }
        downvote.image = UIImage(systemName: "chevron.down")
        downvote.backgroundColor = .systemIndigo
        let swipeActions: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [downvote])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell, let post = cell.post else {
            print("No post could be found for the swiped cell")
            return nil
        }
        let upvote = UIContextualAction(style: .normal, title: "Upvote") { action, view, completionHandler in
            let upvoted = self.upvotePost(post: post)
            
            cell.upvoteSymbol.tintColor = overrideAccentColor(basedOn: upvoted, with: upvoteColor)
            cell.downvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: downvoteColor)
            action.image = UIImage(systemName: upvoted ? "arrow.uturn.backward" : "chevron.up")
            completionHandler(true)
        }
        upvote.image = UIImage(systemName: "chevron.up")
        upvote.backgroundColor = .systemOrange
        let swipeActions: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [upvote])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = posts[indexPath.row]
        
        if let songwhipStr = post.songLinkString, let url = URL(string: songwhipStr) {
            let svc = SFSafariViewController(url: url)
            DispatchQueue.main.async {
                self.present(svc, animated: true)
            }
        }
        else {
            getSongwhipFromLink(linkString: post.trackViewUrl) { result in
                self.posts[indexPath.row].songLinkString = result.url
                let url = URL(string: result.url)!
                let svc = SFSafariViewController(url: url)
                DispatchQueue.main.async {
                    self.present(svc, animated: true)
                }
            }
        }
    }
    
    @objc func userDidTapElement(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let tapLocation = sender.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? PostTableViewCell {
                    guard let post = tappedCell.post else {
                        print("post not set for tappedCell")
                        return
                    }
                    
                    switch sender.view?.tag ?? 0 {
                    case 5:
                        let upvoted = upvotePost(post: post)
                        tappedCell.upvoteSymbol.tintColor = overrideAccentColor(basedOn: upvoted, with: upvoteColor)
                        tappedCell.downvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: downvoteColor)
                    case 6:
                        let loved = heartPost(post: post)
                        tappedCell.updateHeartUI(favoriteStatus: loved)
                    case 7:
                        let downvoted = downvotePost(post: post)
                        tappedCell.downvoteSymbol.tintColor = overrideAccentColor(basedOn: downvoted, with: downvoteColor)
                        tappedCell.upvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: upvoteColor)
                    default:
                        print("No action set in userDidTapElement for tag \(sender.view?.tag ?? 0)")
                    }
                }
            }
        }
    }
    
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
    
    @objc func userPressedMediaButton(_ sender: UIButton) {
        let post = posts[sender.tag]
        guard let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? PostTableViewCell else {
            print("Could not find post cell with given indexPath")
            return
        }
        
        if let oldPlay = whatsPlaying {
            // The user was already playing something, we need to turn that off first
            whatsPlaying?.enterPausedState()
            whatsPlaying = nil
            
            // Also, check that the one we're turning off isn't the user trying to turn it off themselves
            // Otherwise, we must return early
            if oldPlay == cell {
                return
            }
        }
        
        // Now that nothing is playing, let's play the next song
        // (we've already handled the case where the user stops a song above)
        cell.isPlaying = true
        whatsPlaying = cell
        cell.mediaButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        cell.darkeningLayer.opacity = playingArtworkOpacity
        cell.player.initPlayer(url: post.previewUrl) {
            cell.enterPausedState()
        }
        cell.player.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // These actions will occur every time the user switches back to the screen (via the tab bar for example)
        viewDidLoad() 
    }
}
