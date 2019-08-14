//
//  PostViewController.swift
//  Post
//
//  Created by Mitch Merrell on 8/12/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var postController = PostController()
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.dataSource = self
        postTableView.delegate = self
        postTableView.estimatedRowHeight = 45
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts() {
            self.reloadTableView()
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.postTableView.reloadData()
        }
    }
    
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts() {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.reloadTableView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        cell.textLabel?.text = postController.posts[indexPath.row].text
        cell.detailTextLabel?.text = postController.posts[indexPath.row].username
        
        return cell
    }
    
    func presentNewAlert() {
        let alert = UIAlertController(title: "New Post", message: "What's on your mind?", preferredStyle: .alert)
        alert.addTextField { (usernameTextField) in }
        alert.addTextField { (messageTextField) in }
        alert.addAction(UIAlertAction(title: "Post", style: .default, handler: {(action) in
            guard let addPostUser = alert.textFields?[0].text, let addPostMessage = alert.textFields?[1].text else { return }
            self.postController.addNewPost(username: addPostUser, text: addPostMessage, completion: { (success) in
                if success == true {
                    DispatchQueue.main.async {
                        self.reloadTableView()
                    }
                } else {
                    print("Error creating Post")
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewAlert()
        
    }
    
}

extension PostViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= self.postController.posts.count - 1 {
            self.postController.fetchPosts(reset: false) {
                DispatchQueue.main.async{
                    self.reloadTableView()
                }
            }
        }
    }
}
