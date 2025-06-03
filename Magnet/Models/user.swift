import Foundation
import SwiftUI
import FirebaseFirestoreCombineSwift   // gives us @DocumentID
import FirebaseFirestore
// ─────────────────────────────────────────────────────────────
// MARK: - User
// ─────────────────────────────────────────────────────────────

struct Avatar: Codable, Hashable {
    /// Firebase-Storage path or https URL string
    var remoteURL: String
}

struct User: Identifiable, Codable, Hashable {
    @DocumentID var id: String?       // Firestore doc ID
    var userName : String
    var avatar   : Avatar?            // optional
    var familyIDs: [String] = []      // holds Family doc IDs
}
