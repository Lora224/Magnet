// CalendarView.swift

import SwiftUI

struct CalendarView: View {
    let notes: [StickyNote]

    // MARK: – Group notes by "LLLL yyyy" (e.g. "May 2025")
    private var groupedNotes: [String: [StickyNote]] {
        Dictionary(grouping: notes) { note in
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL yyyy"
            return formatter.string(from: note.timeStamp)
        }
    }

    // Sorted list of month‐year keys
    private var sortedMonths: [String] {
        groupedNotes.keys.sorted()
    }

    @State private var selectedMonth: String?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: – Helpers
    private func previewText(for note: StickyNote) -> String {
        if let first = note.payloads.first {
            if let text = first.text, !text.isEmpty {
                return text
            } else if let urlString = first.url {
                return URL(string: urlString)?.lastPathComponent ?? urlString
            }
        }
        return "No preview"
    }

    private func backgroundColor(for note: StickyNote) -> Color {
        switch note.type {
        case .text: return Color.magnetPink.opacity(0.3)
        case .image: return Color.magnetYellow.opacity(0.3)
        case .video: return Color.magnetBlue.opacity(0.3)
        case .audio: return Color.magnetBrown.opacity(0.2)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            ZStack {
                Rectangle()
                    .fill(Color.magnetYellow)
                    .frame(height: 100)

                HStack(spacing: 10) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 50))

                    Text("🎉")
                        .font(.system(size: 50))
                        .padding(.leading, 35)

                    Text("Family 1")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(Color.magnetBrown)
                        .textCase(.uppercase)
                        .padding(.trailing, 35)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 50))
                }
                .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 80, height: 40)
                        .foregroundColor(Color.magnetBrown)
                        .padding(.leading, 40)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)

            // Month selector and grid
            VStack {
                Menu {
                    ForEach(sortedMonths, id: \.self) { month in
                        Button(action: {
                            selectedMonth = month
                        }) {
                            Text(month.capitalized)
                        }
                    }
                } label: {
                    Label("Select Month", systemImage: "calendar")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.magnetBrown)
                }
                .padding(.top, 16)

                if let monthKey = selectedMonth,
                   let notesForMonth = groupedNotes[monthKey] {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(notesForMonth) { note in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(backgroundColor(for: note))
                                    .frame(height: 120)
                                    .overlay(
                                        Text(previewText(for: note))
                                            .padding()
                                            .font(.body)
                                            .foregroundColor(.black),
                                        alignment: .bottomLeading
                                    )
                            }
                        }
                        .padding()
                    }
                }
            }

            Spacer()
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("Calendar")
    }
}

// MARK: – Preview

struct CalendarView_Previews: PreviewProvider {
    static var sampleNotes: [StickyNote] = [
        StickyNote(
            senderID: "user1",
            familyID: "fam1",
            type: .text,
            timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 10))!,
            seen: [:],
            payloads: [Payload(text: "Anna's Birthday 🎂", url: nil)]
        ),
        StickyNote(
            senderID: "user2",
            familyID: "fam1",
            type: .image,
            timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 20))!,
            seen: [:],
            payloads: [Payload(text: nil, url: "https://example.com/photo.jpg")]
        ),
        StickyNote(
            senderID: "user3",
            familyID: "fam1",
            type: .text,
            timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 1))!,
            seen: [:],
            payloads: [Payload(text: "New School Year 📚", url: nil)]
        )
    ]

    static var previews: some View {
        NavigationStack {
            CalendarView(notes: sampleNotes)
        }
    }
}
