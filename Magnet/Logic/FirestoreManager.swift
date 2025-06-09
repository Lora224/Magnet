import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    private init() {}

    func updateCurrentUserName(to newName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is logged in."])))
            return
        }
//        let uid = "y3YT97yZpKOahAbnaqtFfR5cp8r1"

        let userRef = db.collection("users").document(uid)
        userRef.updateData(["name": newName]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getCurrentUserName(completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is logged in."])))
            return
        }
//        let uid = "y3YT97yZpKOahAbnaqtFfR5cp8r1"

        let userRef = db.collection("users").document(uid)
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let document = document, document.exists,
               let name = document.data()?["name"] as? String {
                completion(.success(name))
            } else {
                completion(.failure(NSError(domain: "NoName", code: 404, userInfo: [NSLocalizedDescriptionKey: "Name field not found."])))
            }
        }
    }

}
