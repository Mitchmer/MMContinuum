//
//  PostController.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class PostController {
    
    static var shared = PostController()
    var posts: [Post] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func addComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
        
        let record = CKRecord(comment: newComment)
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let record = record else { completion(nil); return }
            
            let comment = Comment(ckRecord: record)
            self.commentCountIncrement(for: post, completion: nil)
            completion(comment)
        }
    }
    
    func commentCountIncrement(for post: Post, completion: ((Bool)-> Void)?){
        post.commentCount += 1
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        modifyOp.savePolicy = .changedKeys
        modifyOp.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error{
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
        publicDB.add(modifyOp)
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let newPost = Post(caption: caption, photo: image)
        let postRecord = CKRecord(post: newPost)
        publicDB.save(postRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let record = record, let post = Post(ckRecord: record) else { completion(nil); return }
            self.posts.append(post)
            completion(post)
        }
    }
    
    func fetchPosts(completion: @escaping ([Post]?) -> Void){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.postRecordTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion([])
                return
            }
            
            guard let records = records else { completion([]); return }
            
            let postArray = records.compactMap({ Post(ckRecord: $0 )})
            self.posts = postArray
            completion(postArray)
        }
    }
    
    func fetchComments(for post: Post, completion: @escaping([Comment]?) -> Void) {
        let postReference = post.ckRecordID
        let predicate = NSPredicate(format: "%K == %@", Constants.postReferenceKey, postReference)
        let commentIDs = post.comments.compactMap({ $0.ckRecordID })
        let predicate2 = NSPredicate(format: "NOT(ckRecordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: Constants.commentRecordTypeKey, predicate: compoundPredicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            guard let records = records else { completion([]); return }
            
            let commentArray = records.compactMap({ Comment(ckRecord: $0) })
            completion(commentArray)
        }
    }
    
}
