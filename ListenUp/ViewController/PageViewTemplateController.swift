//
//  PagedPostTemplateController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/26/22.
//

import ProgressHUD
import UIKit

enum FeedType {
    case all(Void)
    case favorites(user: User)
    case upvoted(user: User)
    case downvoted(user: User)
}

enum Genre {
    case all,chosen(genre: String)
}

//
//  The following variables are designed to make the user experience more seamless.
//
//  shouldReloadFeed -> This is a global variable that should be set when a crucial
//                      change in the posts or how they're displayed is expected.
//                      For example, this should be true if the user changes their
//                      accent color preference.
//
//  postToComeBackTo -> This is a global variable that tells the PageViewController
//                      which post it should start the user on. This is useful for
//                      when we need to reload the feed but want to keep the user at
//                      the same place in their browsing. This should be set to nil if
//                      the sortOrder is changed.
//
var shouldReloadFeed = false
var postToComeBackTo: Post?

class PageViewTemplateController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var feedType: FeedType!
    var posts: [Post] = []
    
    // Source: https://stackoverflow.com/a/59581292
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(addPost))
        ]
        navigationItem.leftBarButtonItem?.tintColor = jellyColor
        
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.show()
        
        switch feedType {
            // genre will probably end up being global... so I might remove it from the FeedType enum
        case .all():
            var postControllers: [PagedPostViewController] = []
            generatePostsForFeed { sortedPosts in
                self.posts = sortedPosts
                
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PagedPostViewController") as? PagedPostViewController {
                    
                    if let postToComeBackTo = postToComeBackTo, let index = self.posts.firstIndex(where: { post in
                            post.objectId == postToComeBackTo.objectId
                    }) {
                        vc.post = self.posts[index]
                    }
                    else {
                        guard let first = self.posts.first else {
                            return
                        }
                        vc.post = first
                    }
                
                    postControllers.append(vc)
                }
                
                ProgressHUD.dismiss()
                self.setViewControllers(postControllers, direction: .forward, animated: true)
            }
        case .favorites(let user),
                .upvoted(let user),
                .downvoted(let user):
            print(user.username ?? "Username not defined")
        default:
            print("Unknown feed type")
        }
    }
    
    func reloadChildViewControllers() {
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.show()
        var postControllers: [PagedPostViewController] = []
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PagedPostViewController") as? PagedPostViewController {
            guard let first = self.posts.first else {
                return
            }
            vc.post = first
            postControllers.append(vc)
        }
        ProgressHUD.dismiss()
        self.setViewControllers(postControllers, direction: .forward, animated: true)
    }
    
    @objc func addPost() {
        // There is another instance of this function, if you change this one, change that one
        if let newScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as? NewPostViewController {
            newScreen.returningPagedViewController = self
            self.present(newScreen, animated: true, completion: nil)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? PagedPostViewController else {
            return nil
        }
        let currentPost = controller.post
        guard let postIndex = (posts.firstIndex { post in
            post.objectId == currentPost?.objectId
        }) else {
            return nil
        }
        guard postIndex - 1 >= 0 else {
            return nil
        }
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PagedPostViewController") as? PagedPostViewController {
            vc.post = posts[postIndex - 1]
            return vc
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? PagedPostViewController else {
            return nil
        }
        let currentPost = controller.post
        guard let postIndex = (posts.firstIndex { post in
            post.objectId == currentPost?.objectId
        }) else {
            return nil
        }
        guard postIndex + 1 < posts.count else {
            return nil
        }
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PagedPostViewController") as? PagedPostViewController {
            vc.post = posts[postIndex + 1]
            return vc
        }
        
        return nil
    }
    
    func prepareViewControllerForPageView() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldReloadFeed {
            shouldReloadFeed = false
            viewDidLoad()
        }
        else {
            print("\n\nNUMBER OF VIEW CONTROLLERS IN PAGEVIEW: ", self.viewControllers?.count ?? -1, "\n\n")
            if self.viewControllers?.count ?? 0 > 0, let postViewController = (self.viewControllers?[0] as? PagedPostViewController) {
                postViewController.viewWillAppear(true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\n\nNUMBER OF VIEW CONTROLLERS IN PAGEVIEW: ", self.viewControllers?.count ?? -1, "\n\n")
        if self.viewControllers?.count ?? 0 > 0, let postViewController = (self.viewControllers?[0] as? PagedPostViewController) {
            postToComeBackTo = postViewController.post
            
            postViewController.viewWillDisappear(true)
        }
    }
}
