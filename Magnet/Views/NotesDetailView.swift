import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotesDetailView: View {
    @EnvironmentObject var stickyManager: StickyDisplayManager
    @Binding var families: [Family]
    @Binding var selectedFamilyIndex: Int

    /// All notes from the last 7 days, sorted oldest→newest
    let notes: [StickyNote]
    /// Which note we’re showing right now
    @State private var currentIndex: Int

    /// For “seen by” sheet
    @State private var isSeenPanelOpen = false
    @State private var seenUsers: [UserPublic] = []
    /// The reaction this user has selected (if any)
    @State private var myReaction: ReactionType?

    init(
        notes: [StickyNote],
        currentIndex: Int,
        families: Binding<[Family]>,
        selectedFamilyIndex: Binding<Int>
    ) {
        self.notes = notes
        self._families = families
        self._selectedFamilyIndex = selectedFamilyIndex
        self._currentIndex = State(initialValue: currentIndex)
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // 1. Top family bar
                TopFamilyBar(
                    families: $families,
                    selectedIndex: $selectedFamilyIndex
                )
                .padding(.top, 6)

                // 2. Horizontal page‐style swipe
                TabView(selection: $currentIndex) {
                    ForEach(Array(notes.enumerated()), id: \.offset) { idx, note in
                        NoteDetailPage(
                            note: note,
                            myReaction: $myReaction,
                            onToggleSeenPanel: { isSeenPanelOpen = true }
                        )
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentIndex) { newIndex in
                        markSeenAndLoad()

                }
                .onAppear {
                        markSeenAndLoad()
                   
                }

                // 3. Reaction bar
                ReactionBarView(
                    selected: $myReaction,
                    onReact: saveReaction
                )
                .id(currentIndex)
                .padding(.horizontal, 12)
               

            }
            VStack {
                Spacer()
                Image(systemName: "chevron.compact.up")
                    .font(.system(size: 60))
                    .foregroundColor(.magnetBrown)
                    .padding(.bottom, 90)    // lift it above the reaction bar
                    .onTapGesture { isSeenPanelOpen = true }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 6. Seen‐by overlay
            if isSeenPanelOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { isSeenPanelOpen = false }

                SeenUsersPanel(
                    users: seenUsers,
                    isPresented: $isSeenPanelOpen
                )
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: – Helpers

    private func markSeenAndLoad() {
        guard notes.indices.contains(currentIndex) else { return }

        let note = notes[currentIndex]
        let me   = Auth.auth().currentUser!.uid
        let seenKey = "seen.\(me)"

        // ✅ Only write if I’m not in the map yet
        if note.seen[me] == nil {
            Firestore.firestore()
                .collection("StickyNotes")
                .document(note.id.uuidString)
                .updateData([ seenKey : NSNull() ])
        }
        if let raw = note.seen[me] as? String,
           let r = ReactionType(rawValue: raw)
        {
            myReaction = r
        } else {
            myReaction = nil
        }
        // 6. Load seen-by list (excluding the sender)
        let otherIDs = note.seen.keys.filter { $0 != note.senderID }
        guard !otherIDs.isEmpty else {
            self.seenUsers = []
            return
        }

        Firestore
          .firestore()
          .collection("Users")
          .whereField(FieldPath.documentID(), in: otherIDs)
          .getDocuments { snapshot, error in
              guard let docs = snapshot?.documents, error == nil else {
                  print("Failed to fetch seen-by users:", error ?? "")
                  return
              }

              // Map into your lightweight view model
              let publics = docs.compactMap { doc -> UserPublic? in
                  let data = doc.data()
                  guard
                    let name   = data["name"] as? String,
                    let urlStr = data["profilePictureURL"] as? String,
                    let url    = URL(string: urlStr)
                  else { return nil }

                  return UserPublic(id: doc.documentID,
                                    name: name,
                                    avatarURL: url)
              }

              // Update state on the main thread
              DispatchQueue.main.async {
                  self.seenUsers = publics
              }
          }
    }


    private func saveReaction(_ reaction: ReactionType) {
        guard notes.indices.contains(currentIndex) else {
            print("⚠️ Tried to markSeenAndLoad at \(currentIndex), but notes.count = \(notes.count)")
            return
        }
        let note = notes[currentIndex]
        let me = Auth.auth().currentUser!.uid

        Firestore.firestore()
            .collection("StickyNotes")
            .document(note.id.uuidString)
            .updateData(["seen.\(me)": reaction.rawValue]) { _ in
                myReaction = reaction
            }
    }
}



// You’ll also need to build these reusable pieces:
//
// • StickyNoteContentView(note:)        –– exactly your noteContentView()
// • ReactionBarView(selected:onReact:)  –– three tappable magnets
// • SeenUsersPanel(users:isPresented:)   –– slide-up list of avatars & names
struct UserPublic: Identifiable {
    let id: String
    let name: String
    let avatarURL: URL
}
#if DEBUG
import SwiftUI

// MARK: - Local wrapper so we can hold @State / @StateObject
private struct NotesDetailPreview: View {
    @StateObject private var stickyManager = StickyDisplayManager()
    @State private var families: [Family]
    @State private var selectedFamilyIndex: Int
    
    init() {
        // ───────────── sample data ─────────────
        let demoFamily = Family(
            id:        "fam-001",
            name:      "Grandma’s Kitchen",
            inviteURL: "",
            memberIDs: ["u-00", "u-01"],
            red: 0.95, green: 0.83, blue: 0.81,
            profilePic: nil
        )
        
        let demoNotes: [StickyNote] = [
            StickyNote(
                id: UUID(),
                senderID: "u-00",
                familyID: demoFamily.id,
                
                type: .text,
                timeStamp: Date().addingTimeInterval(-3600 * 3),
                seen: [:],
                text: "First batch of cookies\nis in the oven 🍪",
                payloadURL: nil,
                
           
            ),
            StickyNote(
                id: UUID(),
                senderID: "u-01",
                familyID: demoFamily.id,
              
                type: .image,
                timeStamp: Date().addingTimeInterval(-3600),
                seen: [:],
                text: "Look what I made!",
                payloadURL: "https://picsum.photos/seed/123/600/450",
              
               
            )
        ]
        // ───────────────────────────────────────
        
        _families             = State(initialValue: [demoFamily])
        _selectedFamilyIndex  = State(initialValue: 0)
        stickyManager.rawNotes = demoNotes
    }
    
    var body: some View {
        NavigationStack {
            NotesDetailView(
                notes: stickyManager.rawNotes, // same sample notes
                currentIndex: 1,               // show newest first
                families: $families,
                selectedFamilyIndex: $selectedFamilyIndex
            )
            .environmentObject(stickyManager)
        }
    }
}

// MARK: - Xcode canvas / SwiftUI preview
#Preview("Notes Detail") {
    NotesDetailPreview()          // ← no explicit ‘return’
}
#endif
