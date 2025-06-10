import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

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
            "seen": [senderID:nil]

        ]
        db.collection("StickyNotes").addDocument(data: noteData) { error in
            completion(error)
        }
    }
    
    // Save drawing-based sticky note
    static func saveDrawingNote(
        image: UIImage,
        senderID: String,
        familyID: String,
        completion: @escaping (Error?) -> Void
    ) {
        let storage = Storage.storage()
        let db = Firestore.firestore()
        
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "ImageConversion", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"]))
            return
        }
        
        // Create a unique path in Firebase Storage
        let imageID = UUID().uuidString
        let imageRef = storage.reference().child("sticky_notes/\(imageID).jpg")
        
        // Upload image to Firebase Storage
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(error)
                return
            }
            
            // Get download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let url = url else {
                    completion(NSError(domain: "StorageDownload", code: 2, userInfo: [NSLocalizedDescriptionKey: "Download URL not found"]))
                    return
                }
                
                let noteData: [String: Any] = [
                    "id": imageID,
                    "text": "",
                    "type": "drawing",
                    "senderID": senderID,
                    "familyID": familyID,
                    "timeStamp": Timestamp(date: Date()),
                    "payloadURL": url.absoluteString,
                    "seen": [senderID:nil]

                ]
                
                db.collection("StickyNotes").addDocument(data: noteData) { error in
                    completion(error)
                }
            }
        }
    }
    
    // Save photo-based sticky note (from camera)
    
    static func saveCameraPhotoNote(
        image: UIImage,
        senderID: String,
        familyID: String,
        text: String,
        completion: @escaping (Error?) -> Void
    ) {
        let db = Firestore.firestore()
        let storage = Storage.storage().reference()
        
        // ⬅️ down-sample here
        let smallImage = image.resized(maxSide: 2048)
        guard let data = smallImage.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "ImageConversion", code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "JPEG encode failed"]))
            return
        }
        
        let id = UUID().uuidString
        let imageRef = storage.child("sticky_images/\(id).jpg")
        
        imageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                completion(error)
                return
            }
            imageRef.downloadURL { url, error in
                guard let url = url, error == nil else {
                    completion(error)
                    return
                }
                let noteData: [String: Any] = [
                    "id":          id,
                    "type":        "image",
                    "text":        text,
                    "senderID":    senderID,
                    "familyID":    familyID,
                    "timeStamp":   Timestamp(date: Date()),
                    "payloadURL":  url.absoluteString,
                    "seen": [senderID:nil]

                ]
                db.collection("StickyNotes").addDocument(data: noteData, completion: completion)
            }
        }
    }
    
    
    static func saveVoiceNote(audioURL: URL, senderID: String, familyID: String, completion: @escaping (Error?) -> Void) {
            let noteID = UUID().uuidString
            let storagePath = "sticky_voice/\(noteID).m4a"
            let storageRef = Storage.storage().reference().child(storagePath)

            storageRef.putFile(from: audioURL, metadata: nil) { metadata, error in
                if let error = error {
                    completion(error)
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(error)
                        return
                    }

                    guard let downloadURL = url else {
                        completion(NSError(domain: "URLMissing", code: -1))
                        return
                    }

                    let noteData: [String: Any] = [
                        "senderID": senderID,
                        "familyID": familyID,
                        "type": "voice",
                        "payloadURL": downloadURL.absoluteString,
                        "timeStamp": Timestamp(date: Date()),
                        "seen": [:]
                    ]

                    Firestore.firestore()
                        .collection("StickyNotes")
                        .document(noteID)
                        .setData(noteData) { error in
                            completion(error)
                        }
                }
            }
        }


}
