//
//  NoteDetailPage.swift
//  Magnet
//
//  Created by Muze Lyu on 11/6/2025.
//
import SwiftUI
import Combine
struct NoteDetailPage: View {
    let note: StickyNote
    @Binding var myReaction: ReactionType?
    let onToggleSeenPanel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // 3. Profile pic of sender
            SenderProfileView(userID: note.senderID)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding(.top, 16)

            // 4–5. Show content exactly like StickyNoteView, but full-size
            StickyNoteContentView(note: note, mode: .detail)
                .frame(maxWidth: .infinity, maxHeight: .infinity)


        }
    }
}
