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

        let userRef = db.collection("users").document(uid)
        userRef.updateData(["name": newName]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
