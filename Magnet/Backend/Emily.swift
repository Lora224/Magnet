//
//  Emily.swift
//  Magnet
//
//  Created by Siddharth Wani on 6/6/2025.
//
//
//  Emily.swift
//  Magnet
//
//  Created by Emily Zhang on 6/6/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var alertMessage = ""
    @Published var showingAlert = false

    private let db = Firestore.firestore()

    func register(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and password must not be empty."
            showingAlert = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertMessage = "Registration Error: \(error.localizedDescription)"
                self.showingAlert = true
                return
            }

            guard let uid = result?.user.uid else {
                self.alertMessage = "Couldn’t read user UID."
                self.showingAlert = true
                return
            }

            let userData: [String: Any] = [
                "uid": uid,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]

            self.db.collection("users")
                .document(uid)
                .setData(userData) { firestoreError in
                    if let firestoreError = firestoreError {
                        self.alertMessage = "Firestore write failed: \(firestoreError.localizedDescription)"
                    } else {
                        self.alertMessage = "Registration succeeded and UID saved."
                    }
                    self.showingAlert = true
                }
        }
    }

    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and password must not be empty."
            showingAlert = true
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertMessage = "Login Error: \(error.localizedDescription)"
                self.showingAlert = true
                return
            }

            guard let uid = Auth.auth().currentUser?.uid else {
                self.alertMessage = "Couldn’t read user UID after login."
                self.showingAlert = true
                return
            }

            let updateData: [String: Any] = [
                "lastLogin": Timestamp(date: Date())
            ]

            self.db.collection("users")
                .document(uid)
                .updateData(updateData) { firestoreError in
                    if let firestoreError = firestoreError {
                        self.alertMessage = "Firestore update failed: \(firestoreError.localizedDescription)"
                    } else {
                        self.alertMessage = "Login succeeded and Firestore updated."
                    }
                    self.showingAlert = true
                }
        }
    }
}
