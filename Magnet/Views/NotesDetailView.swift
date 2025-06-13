import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotesDetailView: View {
    @EnvironmentObject var stickyManager: StickyDisplayManager
    @Binding var families: [Family]
    @Binding var selectedFamilyIndex: Int

    let notes: [StickyNote]
    @State private var currentIndex: Int

    @State private var isSeenPanelOpen = false
    @State private var seenUsers: [UserPublic] = []
    @State private var myReaction: ReactionType?

    @State private var isSidebarVisible = false

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
        ZStack(alignment: .leading) {
            Image("MainBack")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.2)

            VStack(spacing: 0) {
                // 1. Top family bar + Hamburger
                HStack {
                    Button {
                        withAnimation(.easeInOut) { isSidebarVisible.toggle() }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .frame(width: 60, height: 30)
                            .foregroundColor(.magnetBrown)
                            .padding(16)
                    }

                    Spacer()
                }
                .padding(.top, 12)

                // 2. Horizontal page swipe
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

            // 4. Bottom Chevron for Seen Panel
            VStack {
                Spacer()
                Image(systemName: "chevron.compact.up")
                    .font(.system(size: 60))
                    .foregroundColor(.magnetBrown)
                    .padding(.bottom, 90)
                    .onTapGesture { isSeenPanelOpen = true }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 5. Sidebar layer
            if isSidebarVisible {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isSidebarVisible = false }
                    }
                    .zIndex(1)

                SideBarView()
                    .frame(width: 280)
                    .transition(.move(edge: .leading))
                    .zIndex(2)
            }
        }
        // 6. Seen Panel sheet
        .sheet(isPresented: $isSeenPanelOpen) {
            SeenUsersPanel(users: seenUsers, isPresented: $isSeenPanelOpen)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: – Helpers

    private func markSeenAndLoad() {
        guard notes.indices.contains(currentIndex) else { return }

        let note = notes[currentIndex]
        let me   = Auth.auth().currentUser!.uid
        let seenKey = "seen.\(me)"

        if note.seen[me] == nil {
            Firestore.firestore()
                .collection("StickyNotes")
                .document(note.id.uuidString)
                .updateData([ seenKey : NSNull() ])
        }

        if let raw = note.seen[me] as? String,
           let r = ReactionType(rawValue: raw) {
            myReaction = r
        } else {
            myReaction = nil
        }

        let otherIDs = note.seen.keys.filter { $0 != me }
        guard !otherIDs.isEmpty else {
            self.seenUsers = []
            return
        }

        Firestore
          .firestore()
          .collection("users")
          .whereField(FieldPath.documentID(), in: otherIDs)
          .getDocuments { snapshot, error in
              guard let docs = snapshot?.documents, error == nil else {
                  print("Failed to fetch seen-by users:", error ?? "")
                  return
              }

              let publics: [UserPublic] = docs.map { doc in
                  let data = doc.data()
                  let name = (data["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                             .isEmpty == false
                             ? data["name"] as! String
                             : "Someone"

                  let avatarURL: URL?
                  if let urlStr = data["ProfilePictureURL"] as? String,
                     let url = URL(string: urlStr) {
                      avatarURL = url
                  } else {
                      avatarURL = nil
                  }

                  return UserPublic(id: doc.documentID,
                                    name: name,
                                    avatarURL: avatarURL)
              }

              DispatchQueue.main.async {
                  self.seenUsers = publics
              }
          }
    }

    private func saveReaction(_ reaction: ReactionType) {
        guard notes.indices.contains(currentIndex) else {
            print("⚠️ Tried to saveReaction at \(currentIndex), but notes.count = \(notes.count)")
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

struct UserPublic: Identifiable {
    let id: String
    let name: String
    let avatarURL: URL?
}

