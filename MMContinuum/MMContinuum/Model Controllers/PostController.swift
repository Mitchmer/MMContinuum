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
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
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
    
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
        let predicate = NSPredicate(value: true)
        let querySubscription = CKQuerySubscription(recordType: Constants.postRecordTypeKey, predicate: predicate, subscriptionID: "AllPosts", options: CKQuerySubscription.Options.firesOnRecordCreation)
        publicDB.save(querySubscription) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, nil)
                return
            }
            if subscription != nil {
                completion?(true, nil)
            } else {
                completion?(false, nil)
            }
        }
    }
    
    func addSubscriptionTo(commentFor post: Post, completion: @escaping (Bool, Error?) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", Constants.postReferenceKey, post.ckRecordID)
        let query = CKQuerySubscription(recordType: Constants.commentRecordTypeKey, predicate: predicate, subscriptionID: post.ckRecordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New Comment!"
        notificationInfo.shouldSendContentAvailable = true
        query.notificationInfo = notificationInfo
        publicDB.save(query) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false, nil)
                return
            }
            if subscription != nil {
                print("User subscribed")
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    func removeSubscriptionTo(commentsFor post: Post, completion: @escaping (Bool) -> Void) {
        publicDB.delete(withSubscriptionID: post.ckRecordID.recordName) { (string, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            if let string = string {
                print(string)
            }
            completion(true)
        }
    }
    
    func checkSubscription(to post: Post, completion: @escaping (Bool) -> Void) {
        publicDB.fetch(withSubscriptionID: post.ckRecordID.recordName) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            if subscription != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func toggleSubscriptionTo(commentsFor post: Post, completion: @escaping (Bool) -> Void) {
        checkSubscription(to: post) { (success) in
            if success {
                self.removeSubscriptionTo(commentsFor: post, completion: { (success) in
                    if success {
                        print("Removed subscription from user")
                    }
                })
            } else {
                self.addSubscriptionTo(commentFor: post, completion: { (success, _) in
                    if success {
                        print("Added subscription to user")
                    }
                })
            }
        }
    }
}
