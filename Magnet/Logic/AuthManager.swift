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
            alertMessage = "Firebase not configured."
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
                self.alertMessage = "Registration Error: \(error.localizedDescription)"
                self.showingAlert = true
                completion(false)
                return
            }

            guard let uid = result?.user.uid else {
                self.alertMessage = "Couldn't read user UID."
                self.showingAlert = true
                completion(false)
                return
            }

            self.currentUserID = uid // currentUserID

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
                    self.alertMessage = "Registration succeeded and user saved."
                    self.showingAlert = true
                    completion(true)
                }
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard FirebaseApp.app() != nil else {
            alertMessage = "Firebase not configured."
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
                self.alertMessage = "Login Error: \(error.localizedDescription)"
                self.showingAlert = true
                completion(false)
                return
            }

            guard let uid = Auth.auth().currentUser?.uid else {
                self.alertMessage = "Couldn't read user UID after login."
                self.showingAlert = true
                completion(false)
                return
            }

            self.currentUserID = uid

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

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUserID = nil
        } catch {
            self.alertMessage = "Sign out failed: \(error.localizedDescription)"
            self.showingAlert = true
        }
    }
}

