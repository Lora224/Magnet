import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class Sid: ObservableObject {
    @Published var familyName: String = ""
    @Published var familyEmoji: String = ""
    @Published var red: Double = 1.0
    @Published var green: Double = 0.96
    @Published var blue: Double = 0.85
    @Published var backgroundColor: Color = Color(red: 1.0, green: 0.96, blue: 0.85)
    @Published var userNames: [String] = []

    @Published var navigateToHome: Bool = false
    @Published var alertMessage: String = ""
    @Published var showingAlert: Bool = false

    @Published var currentFamilyID: String? = nil  // Store current family ID

    private let db = Firestore.firestore()

    /// Creates a new family and assigns current user to it
    func regoFam(familyName: String, familyEmoji: String, backgroundColor: Color) {
        let uiColor = UIColor(backgroundColor)
        var r: CGFloat = 1.0, g: CGFloat = 0.96, b: CGFloat = 0.85
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)

        self.familyName = familyName
        self.familyEmoji = familyEmoji
        self.backgroundColor = backgroundColor
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)

        let familyID = UUID().uuidString

        guard let currentUserID = Auth.auth().currentUser?.uid else {
            self.alertMessage = "User not authenticated."
            self.showingAlert = true
            return
        }

        let familyData: [String: Any] = [
            "id": familyID,
            "name": familyName,
            "emoji": familyEmoji,
            "red": self.red,
            "green": self.green,
            "blue": self.blue,
            "createdAt": Timestamp(date: Date()),
            "users": [currentUserID]
        ]

        // Save family and update user profile
        db.collection("families").document(familyID).setData(familyData) { error in
            if let error = error {
                self.alertMessage = "Failed to create family: \(error.localizedDescription)"
                self.showingAlert = true
            } else {
                self.currentFamilyID = familyID
                self.navigateToHome = true

                // Also update the user with current family ID
                self.db.collection("users").document(currentUserID).setData([
                    "currentFamilyID": familyID,
                    "families": [familyID]  // optional: track all families user belongs to
                ], merge: true)
            }
        }
    }

    /// Loads members of the current family
    func fetchFamilyMembers() {
        guard let familyID = currentFamilyID else {
            self.alertMessage = "No family selected."
            self.showingAlert = true
            return
        }

        db.collection("families").document(familyID).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let userIDs = data["users"] as? [String] {
                self.userNames = []
                for uid in userIDs {
                    self.db.collection("users").document(uid).getDocument { userSnapshot, error in
                        if let userData = userSnapshot?.data(),
                           let name = userData["name"] as? String {
                            DispatchQueue.main.async {
                                self.userNames.append(name)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Fetch current user's family ID and then load family details
    func loadCurrentUserFamily() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.alertMessage = "User not authenticated."
            self.showingAlert = true
            return
        }

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let familyID = data["currentFamilyID"] as? String {
                self.currentFamilyID = familyID
                self.fetchFamilyDetails(familyID: familyID)
                self.fetchFamilyMembers()
            } else {
                self.alertMessage = "No family found for this user."
                self.showingAlert = true
            }
        }
    }

    /// Load family meta details (name, emoji, color) given a family ID
    private func fetchFamilyDetails(familyID: String) {
        db.collection("families").document(familyID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.familyName = data["name"] as? String ?? ""
                self.familyEmoji = data["emoji"] as? String ?? ""
                self.red = data["red"] as? Double ?? 1.0
                self.green = data["green"] as? Double ?? 0.96
                self.blue = data["blue"] as? Double ?? 0.85
                self.backgroundColor = Color(red: self.red, green: self.green, blue: self.blue)
            }
        }
    }
}
