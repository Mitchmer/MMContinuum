//
//  Comment.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation

class Comment {
    let text: String
    let timestamp: Date
    
    weak var post: Post?
    
    init(text: String, timestamp: Date = Date(), post: Post) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
}

extension Comment: SearchableRecord {

    func matches(searchTerm: String) -> Bool {
        return self.text.lowercased().contains(searchTerm.lowercased())
    }
}

extension Comment : Equatable {
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.text == rhs.text &&
            lhs.timestamp == rhs.timestamp &&
            lhs.post == rhs.post
    }
}
