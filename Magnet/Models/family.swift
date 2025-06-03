//
//  family.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

import SwiftUI
import FirebaseFirestoreCombineSwift   // gives us @DocumentID
import FirebaseFirestore

struct Family: Identifiable, Codable, Hashable {
    @DocumentID var id: String?       // Firestore document ID
    var name      : String            // e.g. "Smith Family"
    var icon      : String            // e.g. "😍"
    var cardColor  : HexColor          // pastel background, stored as hex string
    
    init(id: String? = nil,
         name: String,
         icon: String,
         cardColor: HexColor) {
        self.id       = id
        self.name     = name
        self.icon     = icon
        self.cardColor = cardColor
    }
}
