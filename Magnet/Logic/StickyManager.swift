import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI

struct PositionedStickyNote: Identifiable {
    let note: StickyNote
    let position: CGPoint
    let rotationAngle: Angle
    let reactions: [ReactionType]
    var id: UUID { note.id }
}

class StickyDisplayManager: ObservableObject {
    @Published var displayedNotes: [PositionedStickyNote] = []

    var viewportNotes: [PositionedStickyNote] {
        displayedNotes
    }

    func loadStickyNotes(for familyID: String, memberIDs: [String], canvasSize: CGSize) {
        let db = Firestore.firestore()
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        db.collection("StickyNotes")
            .whereField("familyID", isEqualTo: familyID)
            .whereField("timeStamp", isGreaterThan: oneWeekAgo)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else { return }

                do {
                    let rawNotes = try docs.compactMap {
                        try $0.data(as: StickyNote.self)
                    }.filter { note in
                        memberIDs.contains(note.senderID)
                    }.sorted { $0.timeStamp > $1.timeStamp }

                    print("📦 Querying StickyNotes for familyID=\(familyID), last 7 days, memberIDs=", memberIDs)

                    DispatchQueue.main.async {
                        let currentIDs = Set(self.displayedNotes.map { $0.note.id })
                        let newIDs = Set(rawNotes.map { $0.id })

                        if currentIDs != newIDs {
                            self.displayedNotes = self.generateNonOverlappingLayout(for: rawNotes, canvasSize: canvasSize)
                        } else {
                            self.displayedNotes = self.displayedNotes.map { existing in
                                if let updated = rawNotes.first(where: { $0.id == existing.note.id }) {
                                    return PositionedStickyNote(
                                        note: updated,
                                        position: existing.position,
                                        rotationAngle: existing.rotationAngle,
                                        reactions: Array(Set(updated.seen.values.compactMap { $0 }))
                                    )
                                } else {
                                    return existing
                                }
                            }
                        }
                    }
                } catch {
                    print("Failed to parse sticky notes: \(error)")
                }
            }
    }

    private func generateNonOverlappingLayout(for notes: [StickyNote], canvasSize: CGSize) -> [PositionedStickyNote] {
        var result: [PositionedStickyNote] = []
        var placedFrames: [CGRect] = []
        let noteSize = CGSize(width: 150, height: 150)

        for note in notes {
            var attempts = 0
            var frame: CGRect
            var center: CGPoint
            var angle: Angle

            repeat {
                let x = CGFloat.random(in: 0...(canvasSize.width - noteSize.width))
                let y = CGFloat.random(in: 0...(canvasSize.height - noteSize.height))
                angle = Angle(degrees: Double.random(in: -45...45))
                center = CGPoint(x: x, y: y)
                frame = CGRect(origin: center, size: noteSize)
                attempts += 1
            } while placedFrames.contains(where: { $0.intersects(frame) }) && attempts < 100

            placedFrames.append(frame)

            let reactions = Array(Set(note.seen.values.compactMap { $0 }))

            result.append(PositionedStickyNote(
                note: note,
                position: center,
                rotationAngle: angle,
                reactions: reactions
            ))
        }

        return result
    }
}

