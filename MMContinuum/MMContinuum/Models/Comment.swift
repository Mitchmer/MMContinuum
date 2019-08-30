//
//  Comment.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation
import CloudKit

class Comment {
    let text: String
    let timestamp: Date
    let ckRecordID: CKRecord.ID
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.ckRecordID, action: .deleteSelf)
    }
    
    weak var post: Post?
    
    init(text: String, timestamp: Date = Date(), post: Post, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.ckRecordID = ckRecordID
    }
    
    init?(ckRecord: CKRecord){
        guard let text = ckRecord[Constants.textKey] as? String, let timestamp = ckRecord[Constants.commentTimeStampKey] as? Date else { return nil }
        self.text = text
        self.timestamp = timestamp
        self.ckRecordID = ckRecord.recordID
    }
}

extension Comment: SearchableRecord {

    func matches(searchTerm: String) -> Bool {
        return self.text.lowercased().contains(searchTerm.lowercased())
    }
}

extension CKRecord {
    convenience init(comment: Comment){
        self.init(recordType: Constants.commentRecordTypeKey, recordID: comment.ckRecordID)
        self.setValue(comment.text, forKey: Constants.textKey)
        self.setValue(comment.timestamp, forKey: Constants.commentTimeStampKey)
        self.setValue(comment.postReference, forKey: Constants.postReferenceKey)
    }
}

extension Comment : Equatable {
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.text == rhs.text &&
            lhs.timestamp == rhs.timestamp &&
            lhs.post == rhs.post
    }
}
