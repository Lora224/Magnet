import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class UserProfileManager {
    static let shared = UserProfileManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    func uploadUserProfilePicture(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is logged in."])))
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "InvalidImage", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid image data."])))
            return
        }

        let avatarRef = storage.reference().child("userProfilePicture/\(uid)/profilePicture.jpg")

        avatarRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            avatarRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "URLMissing", code: 500, userInfo: [NSLocalizedDescriptionKey: "Download URL missing."])))
                    return
                }

                self.db.collection("users").document(uid).updateData([
                    "ProfilePictureURL": downloadURL
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(downloadURL))
                    }
                }
            }
        }
    }
    
    func fetchUserProfilePictureURL(completion: @escaping (Result<String?, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is logged in."])))
            return
        }

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = snapshot?.data(),
               let avatarURLString = data["ProfilePictureURL"] as? String {
                completion(.success(avatarURLString))
            } else {
                completion(.success(nil)) 
            }
        }
    }

}

