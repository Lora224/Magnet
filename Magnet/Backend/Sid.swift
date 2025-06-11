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
        let familyData: [String: Any] = [
            "id": familyID,
            "name": familyName,
            "inviteURL": "",  // Add actual URL generation logic if needed
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
                
                // Update user's family list
                self.db.collection("users").document(currentUserID).setData([
                    "currentFamilyID": familyID,
                    "families": FieldValue.arrayUnion([familyID])
                    
                ], merge: true)
                
                // ✅ Fetch and assign the Family object before navigating
                self.fetchFamilyDetails(familyID: familyID) {
                    DispatchQueue.main.async {
                        self.navigateToHome = true
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
                    id:             data["id"] as? String ?? familyID,
                    name:           data["name"] as? String ?? "",
                    inviteURL:      data["inviteURL"] as? String ?? "",
                    memberIDs:      data["memberIDs"] as? [String] ?? [],
                    red:            data["red"] as? Double ?? 1.0,
                    green:          data["green"] as? Double ?? 0.96,
                    blue:           data["blue"] as? Double ?? 0.85,
                    profilePic:     nil,
                    emoji:          data["emoji"]      as? String   ?? "👪"
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
        
        self.userNames = []
        for uid in memberIDs {
            db.collection("users").document(uid).getDocument { userSnapshot, _ in
                if let userData = userSnapshot?.data(),
                   let name = userData["name"] as? String {
                    DispatchQueue.main.async {
                        self.userNames.append(name)
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
                self.family?.name = newName // Keep local model in sync
            }
        }
    }
}
extension Sid {
    /// Load the given family’s data and then fetch its members.
    func loadFamily(_ id: String) {
        // 1️⃣ Pull down the Family document
        fetchFamilyDetails(familyID: id) {
            // 2️⃣ As soon as you have its `memberIDs`, pull each member’s name
            self.fetchFamilyMembers()
        }
    }
}
