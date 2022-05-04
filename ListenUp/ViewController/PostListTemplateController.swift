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
    
    var indexPathbackup = IndexPath()
    
    var posts: [Post] = []
    var whatsPlaying: PostTableViewCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do anything here that needs to be done for all post lists upon first appearance
        navigationController?.navigationBar.tintColor = jellyColor
        tabBarController?.tabBar.tintColor = jellyColor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Code for context menu
    // Context Menu items received from ShareContextMenu.swift
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        self.indexPathbackup = indexPath
        let post = self.posts[indexPath.row]
        let identifier = NSString(string: post.trackCensoredName)
        return UIContextMenuConfiguration(identifier: identifier,
                                              previewProvider: nil,
                                              actionProvider: { suggestedActions in
            
            return UIMenu(title: "", children: getContextMenuChildren(self, self.posts[indexPath.row]))
        })
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let row = indexPathbackup.row as Optional else {return nil}
        guard let cell = tableView.cellForRow(at: .init(row: row, section: 0)) as? PostTableViewCell else { return nil }

        let visiblePath = UIBezierPath(roundedRect: cell.albumArtworkView.bounds, cornerRadius: 8)
        let parameters = UIPreviewParameters()
        parameters.visiblePath = visiblePath
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell.albumArtworkView, parameters: parameters)
    }

    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        
        guard indexPath.row < posts.count else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        let post = posts[indexPath.row]
        
        cell.post = post
        cell.albumArtworkView.image = UIImage(named: "default.jpg")!
        let clean = UserDefaults.standard.bool(forKey: "prefersCleanContent")
        cell.trackNameLabel?.text = clean ? post.trackCensoredName : post.trackName
        cell.artistNameLabel?.text = post.artistName
        
//        let showsScoreLabel = UserDefaults.standard.bool(forKey: "showsScoreLabel")
//        if !showsScoreLabel {
            cell.scoreLabel?.removeFromSuperview()
//            cell.scoreLabel?.text = ""
//        }
//        else {
//            cell.scoreLabel?.text = String(post.calculatedScore)
//            cell.scoreLabel.sizeThatFits(CGSize(width: 26, height: 26))
//        }
        
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
        
        let doubleTapToFavorite = UITapGestureRecognizer(target: self, action: #selector(favoritePostButItsJustASelectorProxy(_ :)))
        doubleTapToFavorite.numberOfTapsRequired = 2
        cell.addGestureRecognizer(doubleTapToFavorite)
        
        let singleTapToOpen = UITapGestureRecognizer(target: self, action: #selector(openPost(_ :)))
        singleTapToOpen.numberOfTapsRequired = 1
        singleTapToOpen.require(toFail: doubleTapToFavorite)
        cell.addGestureRecognizer(singleTapToOpen)
        
        
        
        if let user = User.current() {
            user.fetchIfNeededInBackground { success, error in
                // lol this is kinda backwards but oh well
                guard let error = error else {
                    cell.styleUpvoteSymbol(value: post.isContainedIn(arr: user.upvotedPosts))
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
        
        cell.albumArtworkView?.load(url: albumArtworkURL, completion: nil)
        
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
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell else {
            print("No post could be found for the swiped cell")
            return nil
        }
        
        let downvote = UIContextualAction(style: .normal, title: "Downvote") { action, view, completionHandler in
            cell.downvote()
            completionHandler(true)
        }
        downvote.image = UIImage(systemName: "chevron.down")
        downvote.backgroundColor = .systemIndigo
        let swipeActions: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [downvote])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell else {
            print("No post could be found for the swiped cell")
            return nil
        }
        let upvote = UIContextualAction(style: .normal, title: "Upvote") { action, view, completionHandler in
            cell.upvote()
            completionHandler(true)
        }
        upvote.image = UIImage(systemName: "chevron.up")
        upvote.backgroundColor = .systemOrange
        let swipeActions: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [upvote])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let post = posts[indexPath.row]
//        
//        openPost(post: post, indexPath: indexPath)
    }
    
    @objc func userDidTapElement(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let tapLocation = sender.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? PostTableViewCell {
                    switch sender.view?.tag ?? 0 {
                    case 5:
                        // Old code, had to manage UI changes outside of upvotePost call
//                        let upvoted = upvotePost(post: post)
//                        tappedCell.upvoteSymbol.tintColor = overrideAccentColor(basedOn: upvoted, with: upvoteColor)
//                        tappedCell.upvoteSymbol.scaleBounce(duration: 0.2)
//                        tappedCell.downvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: downvoteColor)
                        
                        // New code, one unified function for both data and UI changes, all attached to the Post cell
                        tappedCell.upvote()
                    case 6:
                        tappedCell.favorite()
                    case 7:
                        tappedCell.downvote()
                    default:
                        print("No action set in userDidTapElement for tag \(sender.view?.tag ?? 0)")
                    }
                }
            }
        }
    }
    
    
    // this is just turns the favorite action into a selector
    @objc func favoritePostButItsJustASelectorProxy(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let tapLocation = sender.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? PostTableViewCell {
                    tappedCell.favorite()
                }
            }
        }
    }
    
    @objc func openPost(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let tapLocation = sender.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? PostTableViewCell {
                    guard let post = tappedCell.post else {
                        print("post not set for tappedCell")
                        return
                    }
                    
                    openPost(post: post, indexPath: tapIndexPath)
                }
            }
        }
    }
    
    func openPost(post: Post, indexPath: IndexPath) {
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
