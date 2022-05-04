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
        
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.show()
        
        switch feedType {
            // genre will probably end up being global... so I might remove it from the FeedType enum
        case .all():
            var postControllers: [PagedPostViewController] = []
            generatePostsForFeed { sortedPosts in
                self.posts = sortedPosts
                
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
        case .favorites(let user),
                .upvoted(let user),
                .downvoted(let user):
            print(user.username ?? "Username not defined")
        default:
            print("Unknown feed type")
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
        viewDidLoad()
    }
}
