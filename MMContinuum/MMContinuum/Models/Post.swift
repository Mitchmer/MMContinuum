//
//  Post.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation
import UIKit

class Post {
    var comments: [Comment]
    var photoData: Data?
    let timestamp: Date
    let caption: String
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init (timestamp: Date = Date(), caption: String, comments: [Comment] = [], photo: UIImage?) {
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.photo = photo
    }
}

extension Post : SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        var doesContain: Bool = false
        for comment in comments {
            if comment.text.lowercased().contains(searchTerm.lowercased()) {
                doesContain = true
            }
        }
        if self.caption.lowercased().contains(searchTerm.lowercased()) || doesContain {
            return true
        } else {
            return false
        }
    }
}

extension Post : Equatable {
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.comments == rhs.comments &&
            lhs.caption == rhs.caption &&
            lhs.timestamp == rhs.timestamp &&
            lhs.photo == rhs.photo
    }
}
