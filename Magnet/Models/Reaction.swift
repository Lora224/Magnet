import Foundation
import SwiftUI
import FirebaseFirestoreCombineSwift   // gives us @DocumentID
import FirebaseFirestore
/// Simple emoji reaction
struct Reaction: Identifiable, Codable, Hashable {
    @DocumentID var id: String?          // sub-collection ID, if needed
    var emoji     : String               // e.g. "😍"
    var byUserID  : String               // User doc ID
    var createdAt : Timestamp            // Firestore’s server timestamp
}
