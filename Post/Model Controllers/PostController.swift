//
//  PostController.swift
//  Post
//
//  Created by Mitch Merrell on 8/12/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation


class PostController {
    let baseUrl = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        
        guard let unwrappedBaseUrl = baseUrl else { return }
        
        let urlParameters = [ "orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15", ]
        let queryItems = urlParameters.compactMap({ URLQueryItem(name: $0.key, value: $0.value)})
        var urlComponents = URLComponents(url: unwrappedBaseUrl, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { return }
        
        let getterEndpoint = url.appendingPathExtension("json")
        var urlRequest = URLRequest(url: getterEndpoint)
        
        urlRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("Error fetching post \(error): \(error.localizedDescription)")
                completion()
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                let posts: [Post] = postsDictionary.compactMap({ $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
                
            } catch let error {
                print("Error the posts could not be decoded \(error): \(error.localizedDescription)")
                return
            }
            
        }.resume()
        
    }
    
    func addNewPost(username: String, text: String, completion: @escaping (Bool) -> Void) {
        let post = Post(text: text, user: username)
        
        let postData: Data
        
        do {
            let jsonEncoder = JSONEncoder()
            postData = try jsonEncoder.encode(post)
        } catch let error {
            print("Error! There was a problem creating a new post. error: \(error): \(error.localizedDescription)")
            return
        }
        
        guard let url = self.baseUrl else { return }
        let postEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: postEndpoint)
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            // check for errors
            if let error = error {
                print("There was an error with the request \(error) \(error.localizedDescription)")
                completion(false); return
            }
            
            guard let data = data else { return }
            
            if let dataResponseString = String(data: data, encoding: .utf8) {
                print(dataResponseString)
            }
            
            self.posts.append(post)
            print("New post created successfully")
            self.fetchPosts() {
                completion(true)
            }
        }.resume()
    }
}
