//
//  StickyNoteTestView.swift
//  Magnet
//
//  Created by You on 2025-06-04.
//

import SwiftUI
import SwiftData

struct StickyNoteTestView: View {
    // 1) Use FetchDescriptor explicitly so SwiftData can infer the key path
    @Query(
        FetchDescriptor<StickyNote>(
            sortBy: [SortDescriptor(\.timeStamp, order: .reverse)]
        )
    ) private var notes: [StickyNote]
    
    @Environment(\.modelContext) private var modelContext

    @State private var newText: String = ""
    @State private var newURL: String = ""
    @State private var selectedMediaType: MediaType = .text
    @State private var testFamilyID: String = "testFamily001"
    @State private var testSenderID: String = "testUser001"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // ─────────── Input Section ───────────
                GroupBox("Create New StickyNote") {
                    VStack(alignment: .leading, spacing: 12) {
                        // MediaType picker
                        Picker("Media Type", selection: $selectedMediaType) {
                            Text("Text").tag(MediaType.text)
                            Text("Image").tag(MediaType.image)
                            Text("Video").tag(MediaType.video)
                            Text("Audio").tag(MediaType.audio)
                        }
                        .pickerStyle(.segmented)
                        
                        if selectedMediaType == .text {
                            TextField("Enter text payload", text: $newText)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            TextField("Enter URL payload", text: $newURL)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.URL)
                        }
                        
                        Button(action: createStickyNote) {
                            Label("Save StickyNote", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(
                            (selectedMediaType == .text && newText.isEmpty) ||
                            (selectedMediaType != .text && newURL.isEmpty)
                        )
                    }
                    .padding()
                }
                
                // ─────────── List of Existing Notes ───────────
                List {
                    ForEach(notes) { note in
                        Section {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("ID:")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(note.id.uuidString)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                Text("Type: \(note.type.rawValue.capitalized)")
                                    .font(.subheadline)
                                Text("Timestamp: \(note.timeStamp.formatted(date: .numeric, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(note.payloads, id: \.id) { payload in
                                    if let t = payload.text {
                                        Text("• Text: \(t)")
                                            .font(.body)
                                    } else if let u = payload.url {
                                        Text("• URL: \(u)")
                                            .font(.body)
                                            .foregroundColor(.blue)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                }
                                
                                if !note.seen.isEmpty {
                                    Text("Seen by:")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    ForEach(Array(note.seen.keys), id: \.self) { uid in
                                        let reaction = note.seen[uid] ?? nil
                                        if let react = reaction {
                                            Text("• \(uid): \(react.rawValue.capitalized)")
                                                .font(.caption2)
                                        } else {
                                            Text("• \(uid): (no reaction)")
                                                .font(.caption2)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteNotes)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("StickyNote Test")
        }
    }
    
    // MARK: – Create a new StickyNote (no relationships needed)
    private func createStickyNote() {
        let payload: Payload
        if selectedMediaType == .text {
            payload = Payload(text: newText, url: nil)
        } else {
            payload = Payload(text: nil, url: newURL)
        }
        
        let newNote = StickyNote(
            senderID: testSenderID,
            familyID: testFamilyID,
            type: selectedMediaType,
            timeStamp: Date(),
            seen: [testSenderID: reactionForMediaType(selectedMediaType)],
            payloads: [payload]
        )
        
        modelContext.insert(newNote)
        
        newText = ""
        newURL = ""
    }
    
    private func reactionForMediaType(_ type: MediaType) -> ReactionType {
        switch type {
        case .text: return .smile
        case .image: return .liked
        case .video: return .clap
        case .audio: return .smile
        }
    }
    
    // MARK: – Delete notes
    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            modelContext.delete(note)
        }
    }
}

struct StickyNoteTestView_Previews: PreviewProvider {
    static var previews: some View {
        StickyNoteTestView()
            .modelContainer(
                for: [
                    StickyNote.self,
                    Payload.self
                ]
            )
    }
}
