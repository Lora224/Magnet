import SwiftUI
import SwiftData

struct UserManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @State private var name: String = ""
    @State private var appleID: String = ""
    @State private var familiesText: String = ""
    @State private var profilePictureURL: String = ""

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Create a New User")) {
                    TextField("Name", text: $name)
                    TextField("Apple ID", text: $appleID)
                    TextField("Family IDs (comma-separated)", text: $familiesText)
                    TextField("Profile Picture URL", text: $profilePictureURL)

                    Button("Add User") {
                        addUser()
                    }
                    .disabled(name.isEmpty || appleID.isEmpty)
                }
            }

            Divider()

            if users.isEmpty {
                Text("No users yet.")
                    .foregroundColor(.gray)
                    .padding()
            }

            List {
                ForEach(users) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name).font(.headline)
                        Text("id:  \(user.id.uuidString)")
                            .font(.caption)
                        Text("Apple ID: \(user.appleID)").font(.caption)
                        Text("Families: \(user.families.joined(separator: ", "))").font(.subheadline)
                        if let url = user.profilePictureURL, !url.isEmpty {
                            Text("Profile Picture URL: \(url)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Spacer()
                            Button(role: .destructive) {
                                deleteUser(user)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(6)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(8)
                }
            }
        }
    }

    private func addUser() {
        let families = familiesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let newUser = User(
            name: name,
            profilePictureURL: profilePictureURL,
            families: families,
            appleID: appleID
        )
        modelContext.insert(newUser)

        name = ""
        appleID = ""
        familiesText = ""
        profilePictureURL = ""
    }

    private func deleteUser(_ user: User) {
        modelContext.delete(user)
    }
}

#Preview {
    UserManagerView()
}

