//
//  Post.swift
//  Post
//
//  Created by Mitch Merrell on 8/12/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    let text: String
    let timestamp: TimeInterval
    let username: String
    
    init(text: String, user: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.timestamp = timestamp
        self.text = text
        self.username = user
    }
    
    var queryTimeStamp: TimeInterval {
        return self.timestamp - 0.00001
    }
}
