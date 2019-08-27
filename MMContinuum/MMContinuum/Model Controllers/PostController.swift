//
//  PostController.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static var shared = PostController()
    var posts: [Post] = []
    
    func addComment(text: String, post: Post, completion: @escaping (Comment) -> Void) {
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let newPost = Post(caption: caption, photo: image)
        posts.append(newPost)
    }
    
}
