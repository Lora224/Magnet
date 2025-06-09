import SwiftUI
import Firebase
import FirebaseFirestore


struct StickyNoteTestView: View {
    @State private var stickyNotes: [StickyNote] = []
    @State private var message = ""

    var body: some View {
        VStack(spacing: 16) {
            Button("Write Test StickyNote") {
                writeTestStickyNote()
            }
            
            Button("Read StickyNotes") {
                readStickyNotes()
            }

            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(stickyNotes, id: \.id) { note in
                        Text("Note ID: \(note.id.uuidString)")
                        Text("Type: \(note.type.rawValue)")
                        Text("Text: \(note.text ?? "")")
                        Divider()
                    }
                }
            }

            Text(message)
                .foregroundColor(.gray)
        }
        .padding()
    }

    func writeTestStickyNote() {
        let db = Firestore.firestore()
        let note = StickyNote(
            senderID: "test_user_001",
            familyID: "test_family_001",
            type: .text,
            text: "Hello Firestore!",
            payloadURL: nil
        )
        
        do {
            try db.collection("StickyNotes").document(note.id.uuidString).setData(from: note)
            message = "Write success: \(note.id)"
        } catch {
            message = "Write failed: \(error.localizedDescription)"
        }
    }

    func readStickyNotes() {
        let db = Firestore.firestore()
        db.collection("StickyNotes").getDocuments { snapshot, error in
            if let error = error {
                message = "Read failed: \(error.localizedDescription)"
                return
            }
            do {
                stickyNotes = try snapshot?.documents.compactMap {
                    try $0.data(as: StickyNote.self)
                } ?? []
                message = "Read \(stickyNotes.count) notes"
            } catch {
                message = "Parse failed: \(error.localizedDescription)"
            }
        }
    }
}
