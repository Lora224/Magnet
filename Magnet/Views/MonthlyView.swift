// MonthlyView.swift
import SwiftUI

struct MonthlyView: View {
    let month: String
    let notes: [ArchiveNote]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(notes) { note in
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(note.cardColor.color)
                            .frame(height: 120)
                            .shadow(radius: 2)

                        Text(note.text)
                            .padding()
                            .font(.body)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(month)
    }
}
    #Preview {
        MonthlyView(
            month: "January",
            notes: [
                ArchiveNote(
                    text: "Anna's Birthday 🎂",
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 10))!,
                    cardColor: HexColor("#FFF5DA")   // pastel yellow
                ),
                ArchiveNote(
                    text: "Trip to Paris 🇫🇷",
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 20))!,
                    cardColor: HexColor("#F1D3CE")   // pastel pink
                ),
                ArchiveNote(
                    text: "New School Year 📚",
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 1))!,
                    cardColor: HexColor("#D1E9F6")   // pastel blue
                )
            ]
        )
    }


