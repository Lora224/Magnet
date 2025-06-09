//
//  SenderProfileView.swift
//  Magnet
//
//  Created by Emily Zhang on 9/6/2025.
//

import SwiftUI
import FirebaseFirestore

struct SenderProfileView: View {
    let userID: String
    @State private var avatarURL: URL?

    var body: some View {
        Group {
            if let url = avatarURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else {
                        Image("avatarPlaceholder").resizable()
                    }
                }
            } else {
                Image("avatarPlaceholder").resizable()
            }
        }
        .aspectRatio(contentMode: .fill)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 6)
        .onAppear {
            let db = Firestore.firestore()
            db.collection("users").document(userID).getDocument { snapshot, error in
                guard
                    let data = snapshot?.data(),
                    let urlString = data["ProfilePictureURL"] as? String,
                    let url = URL(string: urlString)
                else { return }
                avatarURL = url
            }
        }
    }
}
