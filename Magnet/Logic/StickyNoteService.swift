//  StickyNoteService.swift
//  Magnet
//
//  Created by Yasaman Yazdi on 9/6/2025.
//
//StickyNoteService containts the logic for saving the text/drawn input to database.

import Foundation
import Firebase
import FirebaseFirestore

struct StickyNoteService {
    static func saveTextNote(
        text: String,
        senderID: String,
        familyID: String,
        completion: @escaping (Error?) -> Void
    ) {
        let db = Firestore.firestore()
        
        let noteData: [String: Any] = [
            "id": UUID().uuidString,
            "text": text,
            "type": "text",
            "senderID": senderID,
            "familyID": familyID,
            "timeStamp": Timestamp(date: Date()),
            "payloadURL": "",
            "seen": [:]
        ]
        
        db.collection("StickyNotes").addDocument(data: noteData) { error in
            completion(error)
        }
    }
}




