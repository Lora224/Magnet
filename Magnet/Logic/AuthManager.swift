import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

class AuthManager: ObservableObject {
    @Published var alertMessage = ""
    @Published var showingAlert = false
    @Published var currentUserID: String? = nil
    
    // MARK: - Register
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard FirebaseApp.app() != nil else {
            alertMessage = "Firebase is not configured."
            showingAlert = true
            completion(false)
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and password must not be empty."
            showingAlert = true
            completion(false)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertMessage = "Registration error: \(error.localizedDescription)"
                self.showingAlert = true
                completion(false)
                return
            }
            
            guard let uid = result?.user.uid else {
                self.alertMessage = "Could not read user UID."
                self.showingAlert = true
                completion(false)
                return
            }
            
            self.currentUserID = uid // ⭐️ VERY IMPORTANT
            
            let userData: [String: Any] = [
                "uid": uid,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]
            
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData(userData) { err in
                if let err = err {
                    self.alertMessage = "Firestore error: \(err.localizedDescription)"
                    self.showingAlert = true
                    completion(false)
                } else {
                    // SUCCESS → Do NOT show alert, just complete
                    completion(true)
                }
            }

        }
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard FirebaseApp.app() != nil else {
            alertMessage = "Firebase is not configured."
            showingAlert = true
            completion(false)
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and password must not be empty."
            showingAlert = true
            completion(false)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertMessage = "Login error: \(error.localizedDescription)"
                self.showingAlert = true
                completion(false)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                self.alertMessage = "Could not read user UID after login."
                self.showingAlert = true
                completion(false)
                return
            }
            
            self.currentUserID = uid // ⭐️ VERY IMPORTANT
            
            let db = Firestore.firestore()
            let updateData = ["lastLogin": Timestamp(date: Date())]
            
            db.collection("users").document(uid).updateData(updateData) { err in
                if let err = err {
                    self.alertMessage = "Firestore update failed: \(err.localizedDescription)"
                    self.showingAlert = true
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
