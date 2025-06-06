//
//  Login.swift
//  Magnet
//
//  Created by Emily Zhang on 6/6/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // Firestore reference
    private let db = Firestore.firestore()

    var body: some View {
        ZStack {
            // MARK: – Background Image + Overlay
            Image("loginBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.white.opacity(0.4)
                .ignoresSafeArea()

            // MARK: – Login Card
            VStack(spacing: 30) {
                // Title & Subtitle
                VStack(spacing: 8) {
                    Text("Welcome to Magnet!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("A shared fridge to show your loved ones you care")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 110/255, green: 110/255, blue: 110/255))
                }

                // Email & Password Fields
                Group {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)

                    SecureField("Password", text: $password)
                        .submitLabel(.done)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                }
                .frame(maxWidth: 400)

                // Buttons: Sign Up and Log In
                HStack {
                    Button("Sign Up") {
                        register()
                    }

                    Spacer()

                    Button("Log In") {
                        login()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 400)
            }
            .padding(40)
            .background(Color.white.opacity(0.85))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: – Create New User and write UID to Firestore
    func register() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and password must not be empty."
            showingAlert = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Registration Error: \(error.localizedDescription)"
                showingAlert = true
                return
            }

            // Registration succeeded – grab the new user’s UID
            guard let uid = result?.user.uid else {
                alertMessage = "Couldn’t read user UID."
                showingAlert = true
                return
            }

            // Build the data to store
            let userData: [String: Any] = [
                "uid": uid,
                "email": self.email,
                "createdAt": Timestamp(date: Date())
            ]

            // Write it under a document named “uid” in the “users” collection
            db.collection("users")
                .document(uid)
                .setData(userData) { firestoreError in
                    if let firestoreError = firestoreError {
                        alertMessage = "Firestore write failed: \(firestoreError.localizedDescription)"
                    } else {
                        alertMessage = "Registration succeeded and UID saved."
                    }
                    showingAlert = true
                }
        }
    }

    // MARK: – Log In Existing User and update Firestore timestamp
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and password must not be empty."
            showingAlert = true
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Login Error: \(error.localizedDescription)"
                showingAlert = true
                return
            }

            // Login succeeded – grab the current user’s UID
            guard let uid = Auth.auth().currentUser?.uid else {
                alertMessage = "Couldn’t read user UID after login."
                showingAlert = true
                return
            }

            // Optionally update a “lastLogin” field in Firestore
            let updateData: [String: Any] = [
                "lastLogin": Timestamp(date: Date())
            ]

            db.collection("users")
                .document(uid)
                .updateData(updateData) { firestoreError in
                    if let firestoreError = firestoreError {
                        alertMessage = "Firestore update failed: \(firestoreError.localizedDescription)"
                    } else {
                        alertMessage = "Login succeeded and Firestore updated."
                    }
                    showingAlert = true
                }
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
