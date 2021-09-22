//
//  Note.swift
//  Journal App
//
//  Created by Ewen on 2021/9/21.
//

import Firebase

struct Note {
    var docId: String
    var title: String
    var body: String
    var isStarred: Bool
    var createdAt: Date
    var lastUpdatedAt: Date
    
    init(dic: [String: Any]) {
        self.docId          = dic["docId"] as? String ?? ""
        self.title          = dic["title"] as? String ?? ""
        self.body           = dic["body"] as? String ?? ""
        self.isStarred      = dic["isStarred"] as? Bool ?? false
        self.createdAt      = Timestamp.dateValue(dic["createdAt"] as? Timestamp ?? Timestamp())()
        self.lastUpdatedAt  = Timestamp.dateValue(dic["lastUpdatedAt"] as? Timestamp ?? Timestamp())()
    }
}
