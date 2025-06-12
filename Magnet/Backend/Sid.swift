import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class Sid: ObservableObject {
    @Published var family: Family?
    @Published var userNames: [String] = []
    
    @Published var navigateToHome: Bool = false
    @Published var alertMessage: String = ""
    @Published var showingAlert: Bool = false
    
    @Published var currentFamilyID: String?
    
    private let db = Firestore.firestore()
    
    struct UserSummary: Identifiable {
        let id: String // uid
        let name: String
        let profilePictureURL: String?
    }

    @Published var userSummaries: [UserSummary] = []
    
    // MARK: - Create a new family
    func regoFam(familyName: String, backgroundColor: Color) {
        let uiColor = UIColor(backgroundColor)
        var r: CGFloat = 1.0, g: CGFloat = 0.96, b: CGFloat = 0.85
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            self.alertMessage = "User not authenticated."
            self.showingAlert = true
            return
        }
        
        let familyID = UUID().uuidString
        
        // Generate unique invite code
        generateUniqueInviteCode { inviteCode in
            guard let inviteCode = inviteCode else {
                self.alertMessage = "Failed to generate invite code."
                self.showingAlert = true
                return
            }
            
            let familyData: [String: Any] = [
                "id": familyID,
                "name": familyName,
                "inviteURL": inviteCode,
                "memberIDs": [currentUserID],
                "red": Double(r),
                "green": Double(g),
                "blue": Double(b)
            ]
            
            self.db.collection("families").document(familyID).setData(familyData) { error in
                if let error = error {
                    self.alertMessage = "Failed to create family: \(error.localizedDescription)"
                    self.showingAlert = true
                } else {
                    self.currentFamilyID = familyID
                    
                    self.db.collection("users").document(currentUserID).setData([
                        "currentFamilyID": familyID,
                        "families": FieldValue.arrayUnion([familyID])
                    ], merge: true)
                    
                    self.fetchFamilyDetails(familyID: familyID) {
                        DispatchQueue.main.async {
                            self.navigateToHome = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Load current user's family
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
                self.fetchFamilyDetails(familyID: familyID) {
                    self.fetchFamilyMembers()
                }
            } else {
                self.alertMessage = "No family found for this user."
                self.showingAlert = true
            }
        }
    }
    
    // MARK: - Fetch family data
    private func fetchFamilyDetails(familyID: String, completion: @escaping () -> Void = {}) {
        db.collection("families").document(familyID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let family = Family(
                    id: data["id"] as? String ?? familyID,
                    name: data["name"] as? String ?? "",
                    inviteURL: data["inviteURL"] as? String ?? "",
                    memberIDs: data["memberIDs"] as? [String] ?? [],
                    red: data["red"] as? Double ?? 1.0,
                    green: data["green"] as? Double ?? 0.96,
                    blue: data["blue"] as? Double ?? 0.85,
                    profilePic: nil,
                    emoji: data["emoji"] as? String ?? "👪"
                )
                DispatchQueue.main.async {
                    self.family = family
                    completion()
                }
            }
        }
    }
    
    // MARK: - Load member names
    func fetchFamilyMembers() {
        guard let memberIDs = family?.memberIDs else { return }
        
        self.userSummaries = []
        
        for uid in memberIDs {
            db.collection("users").document(uid).getDocument { userSnapshot, _ in
                if let userData = userSnapshot?.data() {
                    let name = userData["name"] as? String ?? "Unnamed"
                    let photoURL = userData["ProfilePictureURL"] as? String
                    
                    let summary = UserSummary(id: uid, name: name, profilePictureURL: photoURL)
                    DispatchQueue.main.async {
                        self.userSummaries.append(summary)
                    }
                }
            }
        }
    }
    
    func updateFamilyName(newName: String) {
        guard let familyID = self.family?.id else {
            print("No family ID found.")
            return
        }
        
        db.collection("families").document(familyID).updateData([
            "name": newName
        ]) { error in
            if let error = error {
                print("Error updating family name: \(error)")
            } else {
                print("Family name updated successfully.")
                self.family?.name = newName
            }
        }
    }
    
    // Generates a random alphanumeric string
    func randomAlphaNumericString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    // Recursively checks Firestore for uniqueness
    func generateUniqueInviteCode(completion: @escaping (String?) -> Void) {
        let code = randomAlphaNumericString(length: 8)
        db.collection("families")
            .whereField("inviteURL", isEqualTo: code)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking code: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let snapshot = snapshot, snapshot.documents.isEmpty {
                    completion(code)
                } else {
                    self.generateUniqueInviteCode(completion: completion)
                }
            }
    }
    
    func joinFamily(with code: String, completion: @escaping () -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            self.alertMessage = "User not authenticated."
            self.showingAlert = true
            return
        }
        
        db.collection("families")
            .whereField("inviteURL", isEqualTo: code)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.alertMessage = "Error finding family: \(error.localizedDescription)"
                    self.showingAlert = true
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self.alertMessage = "Invalid invite code."
                    self.showingAlert = true
                    return
                }
                
                let familyID = document.documentID
                
                self.db.collection("families").document(familyID).updateData([
                    "memberIDs": FieldValue.arrayUnion([currentUserID])
                ])
                
                self.db.collection("users").document(currentUserID).setData([
                    "currentFamilyID": familyID,
                    "families": FieldValue.arrayUnion([familyID])
                ], merge: true)
                
                self.fetchFamilyDetails(familyID: familyID) {
                    DispatchQueue.main.async {
                        self.navigateToHome = true
                        completion()
                    }
                }
            }
    }
    
    
    
    func extractInviteCode(from input: String) -> String {
        if let url = URL(string: input),
           let lastComponent = url.pathComponents.last,
           lastComponent.count == 8 {
            return lastComponent
        }
        return input
    }
    
    func loadFamily(_ id: String) {
        fetchFamilyDetails(familyID: id) {
            self.fetchFamilyMembers()
        }
    }
}
