//
//  Post.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post {
    var comments: [Comment]
    var photoData: Data?
    let timestamp: Date
    let caption: String
    var commentCount: Int
    var ckRecordID: CKRecord.ID
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init (timestamp: Date = Date(), caption: String, comments: [Comment] = [], commentCount: Int = 0, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), photo: UIImage?) {
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.commentCount = commentCount
        self.ckRecordID = ckRecordID
        self.photo = photo
    }
    
    init?(ckRecord: CKRecord){
        guard let caption = ckRecord[Constants.captionKey] as? String, let timestamp = ckRecord[Constants.postTimestampKey] as? Date, let commentCount = ckRecord[Constants.commentCountKey] as? Int, let imageAsset = ckRecord[Constants.photoKey] as? CKAsset else { return nil }
        self.caption = caption
        self.timestamp = timestamp
        self.commentCount = commentCount
        
        do {
            self.photoData = try Data(contentsOf: imageAsset.fileURL!)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        
        self.ckRecordID = ckRecord.recordID
        self.comments = []
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

extension CKRecord {
    convenience init(post: Post) {
        
        self.init(recordType: Constants.postRecordTypeKey, recordID: post.ckRecordID)
        self.setValue(post.caption, forKey: Constants.captionKey)
        self.setValue(post.timestamp, forKey: Constants.postTimestampKey)
        self.setValue(post.commentCount, forKey: Constants.commentCountKey)
        self.setValue(post.imageAsset, forKey: Constants.photoKey)
        
        
    }
}
