//
//  CalendarView1.swift
//  Magnet
//
//  Created by Siddharth Wani on 12/6/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// StatefulPreviewWrapper (supports two-way binding in preview)
struct StatefulPreviewWrapper<A, B, Content: View>: View {
    @State var valueA: A
    @State var valueB: B
    var content: (Binding<A>, Binding<B>) -> Content
    
    init(_ values: (A, B), content: @escaping (Binding<A>, Binding<B>) -> Content) {
        self._valueA = State(initialValue: values.0)
        self._valueB = State(initialValue: values.1)
        self.content = content
    }
    
    var body: some View {
        content($valueA, $valueB)
    }
}


struct CalendarView1: View {
    @EnvironmentObject var stickyManager: StickyDisplayManager
    @Binding var families: [Family]
    @Binding var selectedFamilyIndex: Int
    
    // Sorting notes oldest → newest
    private var sortedNotes: [StickyNote] {
        stickyManager.rawNotes.sorted { $0.timeStamp < $1.timeStamp }
    }
    
    @State private var selectedIndex: Int? = nil
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100), spacing: 300)
    ]

    
    var body: some View {
        NavigationStack {
            VStack {
                TopFamilyBar(
                    families: $families,
                    selectedIndex: $selectedFamilyIndex
                )
                .padding(.top, 6)
                .frame(maxWidth: .infinity, alignment: .top)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                                                ForEach(Array(sortedNotes.enumerated()), id: \.offset) { index, note in
                        
                                                    StickyNoteView(
                                                        note: note,
                                                        reactions: [],  // pass empty or your reactions array here
                                                        families: $families,
                                                        selectedFamilyIndex: $selectedFamilyIndex
                                                    )
                        
                                                        .frame(width: 100, height: 150)  // Adjust thumbnail size
                                                        .onTapGesture {
                                                            selectedIndex = index
                                                        }
                                                }
                        
//                        ForEach(stickyManager.viewportNotes) { positioned in
//                            StickyNoteView(note: positioned.note, reactions: positioned.reactions,  families: $families,  selectedFamilyIndex: $selectedFamilyIndex)
//                                .rotationEffect(positioned.rotationAngle)
//                                .position(positioned.position)
//                                .id(positioned.id)
//                                .zIndex(1)
//                        }
                    }
                    
                    .padding()
                }
            }
            
            .navigationDestination(isPresented: Binding(
                get: { selectedIndex != nil },
                set: { if !$0 { selectedIndex = nil } }
            )) {
                if let index = selectedIndex {
                    NotesDetailView(
                        notes: sortedNotes,
                        currentIndex: index,
                        families: $families,
                        selectedFamilyIndex: $selectedFamilyIndex
                    )
                }
            }
            .onAppear(perform: loadUserFamilies)
            .onChange(of: selectedFamilyIndex) { _ in
                loadNotesForCurrentFamily()
            }
        }
    }
    
    private func loadUserFamilies() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("families")
          .whereField("memberIDs", arrayContains: uid)
          .getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.families = docs.compactMap { doc in
                let data = doc.data()
                return Family(
                    id:          doc.documentID,
                    name:        data["name"]       as? String   ?? "<No Name>",
                    inviteURL:   data["inviteURL"]  as? String   ?? "",
                    memberIDs:   data["memberIDs"]  as? [String] ?? [],
                    red:         data["red"]        as? Double   ?? 1.0,
                    green:       data["green"]      as? Double   ?? 1.0,
                    blue:        data["blue"]       as? Double   ?? 1.0,
                    profilePic:  data["profilePic"] as? Data,
                    emoji:       data["emoji"]      as? String   ?? "👪"
                )

            }
            // start at the first family
            self.selectedFamilyIndex = 0
            loadNotesForCurrentFamily()
        }
    }

    private func loadNotesForCurrentFamily() {
        guard families.indices.contains(selectedFamilyIndex) else { return }
        let family = families[selectedFamilyIndex]
        stickyManager.loadStickyNotes(
            for: family.id,
            memberIDs: family.memberIDs,
            canvasSize: UIScreen.main.bounds.size
        )
    }
}

struct StickyNoteThumbnailView: View {
    let note: StickyNote
    
    var body: some View {
        ZStack {
            switch note.type {
            case .text:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.3))
                Text(note.text ?? "")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .padding()
                
            case .drawing, .image, .video:
                if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .frame(width: 40, height: 40)
                        default:
                            ProgressView()
                        }
                    }
                } else {
                    Color.gray
                        .frame(width: 150, height: 150)
                        .overlay(Text("No Image"))
                }
                
            case .audio:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.3))
                Image(systemName: "waveform.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.black)
            }
        }
        .frame(width: 150, height: 150)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// MARK: - Preview
#if DEBUG
private struct CalendarPreviewWrapper: View {
    @StateObject private var stickyManager: StickyDisplayManager = {
        let manager = StickyDisplayManager()
        manager.rawNotes = Self.makeDemoNotes()
        return manager
    }()
    
    static func makeDemoNotes() -> [StickyNote] {
        let demoFamilyID = "fam-001"
        return [
            StickyNote(
                id: UUID(),
                senderID: "u-00",
                familyID: demoFamilyID,
                type: .text,
                timeStamp: Date().addingTimeInterval(-3600 * 3),
                seen: [:],
                text: "Cookies are ready 🍪",
                payloadURL: nil
            ),
            StickyNote(
                id: UUID(),
                senderID: "u-01",
                familyID: demoFamilyID,
                type: .image,
                timeStamp: Date().addingTimeInterval(-3600),
                seen: [:],
                text: "Look what I baked!",
                payloadURL: "https://picsum.photos/seed/123/600/450"
            ),
            StickyNote(
                id: UUID(),
                senderID: "u-01",
                familyID: demoFamilyID,
                type: .audio,
                timeStamp: Date().addingTimeInterval(-7200),
                seen: [:],
                text: "Listen to grandma's story 🎤",
                payloadURL: nil
            )
        ]
    }
    
    var body: some View {
        let families = [
            Family(
                id: "fam-001",
                name: "Grandma’s Kitchen",
                inviteURL: "",
                memberIDs: ["u-00", "u-01"],
                red: 0.95, green: 0.83, blue: 0.81,
                profilePic: nil,
                emoji: "👩‍🍳"
            )
        ]
        
        StatefulPreviewWrapper((families, 0)) { familiesBinding, selectedFamilyIndexBinding in
            CalendarView1(
                families: familiesBinding,
                selectedFamilyIndex: selectedFamilyIndexBinding
            )
            .environmentObject(stickyManager)
        }
    }
}


#Preview("Calendar View") {
    CalendarPreviewWrapper()
}
#endif
