//
//  NotesManager.swift
//  Journal App
//
//  Created by Ewen on 2021/9/21.
//

import Foundation
import Firebase

protocol NotesManagerProtocol {
    func notesRetrieved(notes: [Note])
}


class NotesManager {
    var delegate: NotesManagerProtocol?
    var listenerReg: ListenerRegistration?
    
    //得到note
    func getNotes(starredOnly: Bool = false) {
        var query: Query = Firestore.firestore().collection("notes")
        
        //每次進入 getNotes，listenerReg 要先移除再換成新的
        listenerReg?.remove()
        
        //starredOnly為真，query 只包含 isStarred 欄位為 true 的 documents
        if starredOnly {
            query = query.whereField("isStarred", isEqualTo: true)
        }
        
        listenerReg = query.addSnapshotListener { querySnapshot, error in
            if error == nil,  querySnapshot != nil {
                var notes = [Note]()
                for queryDocSnapshot in querySnapshot!.documents {
                    let note = Note(dic: queryDocSnapshot.data())
                    notes.append(note)
                    notes.sort { note1, note2 in
                        let note1Date = note1.createdAt
                        let note2Date = note2.createdAt
                        return note1Date < note2Date
                    }
                }
                DispatchQueue.main.async {
                    self.delegate?.notesRetrieved(notes: notes)
                }
            }
        }
    }
    
    //更新note
    func saveNote(_ note: Note) {
        Firestore.firestore().collection("notes").document(note.docId).setData(noteToDic(note))
    }
    func noteToDic(_ note: Note) -> [String: Any] {
        var dic = [String: Any]()
        dic["docId"]            = note.docId
        dic["title"]            = note.title
        dic["body"]             = note.body
        dic["isStarred"]        = note.isStarred
        dic["createdAt"]        = note.createdAt
        dic["lastUpdatedAt"]    = note.lastUpdatedAt
        return dic
    }
    
    //更新note的isStarred欄
    func updateStarStatus(docId: String, isStarred: Bool) {
        Firestore.firestore().collection("notes").document(docId).updateData(["isStarred": isStarred])
    }
    
    //刪除note
    func deleteNote(_ note: Note) {
        Firestore.firestore().collection("notes").document(note.docId).delete()
    }
    
}

