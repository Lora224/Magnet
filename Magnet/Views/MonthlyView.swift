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
                            .fill(note.color)
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
                ArchiveNote(text: "Buy groceries", date: Date(), color: .yellow),
                ArchiveNote(text: "Meeting notes", date: Date(), color: .pink),
                ArchiveNote(text: "Vacation plan", date: Date(), color: .blue)
            ]
        )
    }


