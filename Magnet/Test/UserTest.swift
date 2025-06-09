import SwiftUI
import SwiftData
import FirebaseAuth
import Foundation
import Firebase
import FirebaseFirestore

struct UserDTO: Codable, Identifiable {
    @DocumentID var id: String? = nil
    var name: String
    var profilePictureURL: String?
    var families: [String?]
    var email: String
    var uid: UUID
}



struct UserManagerView: View {
    @State private var users: [UserDTO] = []
    @State private var selectedFamilyID: String = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Button("Read All Users") {
                fetchUsers()
            }

            TextField("Target Family ID", text: $selectedFamilyID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Add Me to Family") {
                addCurrentUserToFamily()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(users) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name).font(.headline)
                            Text("UID: \(user.uid.uuidString)")
                            Text("Email: \(user.email)")
                            Text("Families: \(user.families.compactMap { $0 }.joined(separator: ", "))")
                            if let url = user.profilePictureURL {
                                Text("Profile: \(url)").font(.caption2).foregroundColor(.gray)
                            }
                            Divider()
                        }
                        .padding(.horizontal)
                    }
                }
            }

            Text(message).foregroundColor(.gray)
        }
        .padding(.top)
    }

    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
                return
            }
            do {
                users = try snapshot?.documents.compactMap {
                    try $0.data(as: UserDTO.self)
                } ?? []
                message = "Fetched \(users.count) users"
            } catch {
                message = "Decode error: \(error.localizedDescription)"
            }
        }
    }

    func addCurrentUserToFamily() {
        guard let firebaseUser = Auth.auth().currentUser else {
            message = "Not logged in"
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(firebaseUser.uid)

        userRef.getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                do {
                    var user = try snapshot.data(as: UserDTO.self)

                    if !user.families.contains(where: { $0 == selectedFamilyID }) {
                        user.families.append(selectedFamilyID)
                        try userRef.setData(from: user)
                        message = "User added to family: \(selectedFamilyID)"
                    } else {
                        message = "Already in that family"
                    }
                } catch {
                    message = "Error updating user: \(error.localizedDescription)"
                }
            } else {
                // If user doc doesn't exist, create a new one
                let newUser = UserDTO(
                    name: firebaseUser.displayName ?? "Anonymous",
                    profilePictureURL: firebaseUser.photoURL?.absoluteString,
                    families: [selectedFamilyID],
                    email: firebaseUser.email ?? "unknown",
                    uid: UUID()
                )

                do {
                    try userRef.setData(from: newUser)
                    message = "New user created and added to family."
                } catch {
                    message = "Failed to create user: \(error.localizedDescription)"
                }
            }
        }
    }
}
