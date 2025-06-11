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
                    if notes.indices.contains(newIndex) {
                        markSeenAndLoad()
                    }
                }
                .onAppear {
                    if notes.indices.contains(currentIndex) {
                        print("📑 NotesDetailView appeared with notes.count =", notes.count, "currentIndex =", currentIndex)
                          
                        markSeenAndLoad()
                    }
                }

                // 3. Reaction bar
                ReactionBarView(
                    selected: $myReaction,
                    onReact: saveReaction
                )
                .padding(.vertical, 12)
            }

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
        guard notes.indices.contains(currentIndex) else {
            print("⚠️ Tried to markSeenAndLoad at \(currentIndex), but notes.count = \(notes.count)")
            return
        }
        let note = notes[currentIndex]
        let me   = Auth.auth().currentUser!.uid

        // 7. Mark it seen
        Firestore.firestore()
          .collection("StickyNotes")
          .document(note.id.uuidString)
          .updateData(["seen.\(me)": true])

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

