import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct StickyNoteService {
    // Save text-based sticky note
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
                    "seen": [:]
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
        completion: @escaping (Error?) -> Void
    ) {
        let storage = Storage.storage()
        let db = Firestore.firestore()

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "ImageConversion", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"]))
            return
        }

        let imageID = UUID().uuidString
        let imageRef = storage.reference().child("camera_photos/\(imageID).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(error)
                return
            }

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
                    "type": "photo",
                    "senderID": senderID,
                    "familyID": familyID,
                    "timeStamp": Timestamp(date: Date()),
                    "payloadURL": url.absoluteString,
                    "seen": [:]
                ]

                db.collection("StickyNotes").addDocument(data: noteData) { error in
                    completion(error)
                }
            }
        }
    }
}
