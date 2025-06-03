//
//  ArchiveNote.swift
//  Magnet
//
//  Created by Siddharth Wani on 3/6/2025.
//

import SwiftUI

struct ArchiveNote: Identifiable {
    let id = UUID()
    let text: String
    let date: Date
    let color: Color
}
let sampleNotes: [ArchiveNote] = [
    ArchiveNote(text: "Anna's Birthday 🎂", date: DateComponents(calendar: .current, year: 2025, month: 5, day: 10).date!, color: .yellow),
    ArchiveNote(text: "Trip to Paris 🇫🇷", date: DateComponents(calendar: .current, year: 2025, month: 5, day: 20).date!, color: .pink),
    ArchiveNote(text: "New School Year 📚", date: DateComponents(calendar: .current, year: 2025, month: 9, day: 1).date!, color: .blue)
]
