//
//  FeedViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/13/22.
//

import Foundation
import Parse
import SafariServices
import UIKit
import AVFAudio

let nonPlayingArtworkOpacity: Float = 0.4
let playingArtworkOpacity: Float = 0.0

// idk where else to put this rn
func overrideAccentColor(basedOn condition: Bool, with override: UIColor) -> UIColor {
    return condition ? override : UIColor(named: "AccentColor")!
}

let upvoteColor = UIColor.systemOrange
let downvoteColor = UIColor.systemIndigo
let favoriteColor = UIColor.systemPink

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    var whatsPlaying: PostTableViewCell? = nil
    
    override func viewDidLoad() {
        navigationItem.title = "Feed"
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        
        let logoutButton = UIBarButtonItem(title: "TempLogOut", style: .plain, target: self, action: #selector(userLoggedOut))
        logoutButton.tintColor = UIColor.systemRed
        navigationItem.leftBarButtonItems = [
            logoutButton
        ]
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(addPost))
        ]
        
        let query = Post.query()
        
        query?.findObjectsInBackground(block: { returnedPosts, error in
            guard let postsReturned = returnedPosts as? [Post] else {
                print("An error occurred...")
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    print("Could not get description of error.")
                }
                return
            }
            
            self.posts = postsReturned
            self.sortPosts()
            self.tableView.reloadData()
            
        })
    }
    
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
                    let favoriteStatus = post.isContainedIn(arr: user.favoritedPosts)
                    cell.upvoteSymbol.tintColor = overrideAccentColor(basedOn: post.isContainedIn(arr: user.upvotedPosts), with: upvoteColor)
                    cell.downvoteSymbol.tintColor = overrideAccentColor(basedOn: post.isContainedIn(arr: user.downvotedPosts), with: downvoteColor)
                    cell.heartIcon.image = UIImage(systemName: favoriteStatus ? "heart.fill" : "heart")
                    cell.heartIcon.tintColor = overrideAccentColor(basedOn: favoriteStatus, with: favoriteColor)
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
                        heartPost(post: post)
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
    
    @objc func addPost() {
        print("user did press add button")
        
        if let newScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as? NewPostViewController {
            newScreen.returningViewController = self
            self.present(newScreen, animated: true, completion: nil)
        }
    }
    
    @objc func userLoggedOut() {
        User.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    // These are just quick and dirty implementations of these for now
    
    // upvote:
    //      - A given user should only be able to upvote a post once, if they have not already
    //      - If the given user has downvoted the post already, their downvote should be subtracted and undone
    //      - The post should be added to the given user's upvotedPosts array
    //      - If the user has already upvoted, their upvote should be subtracted and undone (including removing the post from their upvotedPosts array)
    // Keep in mind that posts should be identified by their objectId property. SongResult objects should be identified by their trackId property
    
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
    func heartPost(post: Post) {
        print("user favorited \(post.trackName)")
        User.current()!.favoritedPosts.append(post)
        User.current()!.saveInBackground()
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
    
    func sortPosts() {
        self.posts.sort { post1, post2 in
            
            let scoreCompare = post1.calculatedScore > post2.calculatedScore
            let scoreEqual = post1.calculatedScore == post2.calculatedScore
            
            guard let date1 = post1.createdAt, let date2 = post2.createdAt else {
                return scoreCompare || post1.downvoteCount < post2.downvoteCount && scoreEqual
            }
            
            return scoreCompare || date1.timeIntervalSinceNow > date2.timeIntervalSinceNow && scoreEqual
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
}

extension PostTableViewCell {
    func enterPausedState() {
        self.isPlaying = false
        self.player.pause()
        self.darkeningLayer.opacity = nonPlayingArtworkOpacity
        self.mediaButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    }
}



