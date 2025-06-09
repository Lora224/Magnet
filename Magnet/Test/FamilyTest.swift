import SwiftUI
import SwiftData
import FirebaseAuth
import Foundation
import Firebase
import FirebaseFirestore




struct FamilyDTO: Codable, Identifiable {
    @DocumentID var id: String? = nil
    var name: String
    var inviteURL: String
    var memberIDs: [String]
    var red: Double
    var green: Double
    var blue: Double
}



struct FamilyManagerView: View {
    @State private var families: [FamilyDTO] = []
    @State private var message = ""

    var body: some View {
        VStack(spacing: 16) {
            Button("Read Families") {
                fetchFamilies()
            }

            Button("Write New Family (with logged-in user)") {
                createFamilyWithLoggedInUser()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(families) { family in
                        VStack(alignment: .leading) {
                            Text(family.name).bold()
                            Text("Members: \(family.memberIDs.joined(separator: ", "))")
                            Text("Color: R:\(family.red) G:\(family.green) B:\(family.blue)")
                            Divider()
                        }
                    }
                }
            }

            Text(message).foregroundColor(.gray)
        }
        .padding()
    }

    func fetchFamilies() {
        Firestore.firestore().collection("families").getDocuments { snapshot, error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
                return
            }
            do {
                self.families = try snapshot?.documents.compactMap {
                    try $0.data(as: FamilyDTO.self)
                } ?? []
                message = "Fetched \(families.count) families"
            } catch {
                message = "Decode error: \(error.localizedDescription)"
            }
        }
    }

    func createFamilyWithLoggedInUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "No user logged in"
            return
        }
        let idString = UUID().uuidString

        let db = Firestore.firestore()
        let docRef = db.collection("families").document() // Let Firestore create the ID
        let newFamily = FamilyDTO(
            id: idString, 
            name: "Test Family",
            inviteURL: "https://...",
            memberIDs: [uid],
            red: 1.0, green: 0.96, blue: 0.85
        )

        do {
            try Firestore.firestore().collection("families").addDocument(from: newFamily)
            message = "Family created: \(newFamily.name)"
        } catch {
            message = "Write error: \(error.localizedDescription)"
        }
    }
}


#Preview{
    FamilyManagerView()
}
