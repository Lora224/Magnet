// MonthlyView.swift

import SwiftUI

struct MonthlyView: View {
    let month: String
    let notes: [StickyNote]

    // Group notes by "MMMM yyyy" string (e.g. "May 2025")
    private var groupedNotes: [String: [StickyNote]] {
        Dictionary(grouping: notes) { note in
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL yyyy"
            return formatter.string(from: note.timeStamp)
        }
    }

    // Turn the dictionary into a sorted array of (monthString, notes) tuples
    private var groupedEntries: [(key: String, value: [StickyNote])] {
        groupedNotes
            .map { (key: $0.key, value: $0.value) }
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with chevrons, emoji, title
            ZStack {
                Rectangle()
                    .fill(Color.magnetYellow)
                    .frame(height: 90)

                HStack(spacing: 10) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 40))

                    Text("🎉")
                        .font(.system(size: 45))
                        .padding(.leading, 35)

                    Text("Family 1")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(Color.magnetBrown)
                        .textCase(.uppercase)
                        .padding(.trailing, 35)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 40))
                }
                .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 60, height: 30)
                        .foregroundColor(Color.magnetBrown)
                        .padding(.leading, 30)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            Text("Notes")
                .font(.title2)
                .bold()
                .padding(.top, 16)

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(groupedEntries, id: \.key) { entry in
                        let monthString = entry.key
                        let notesForMonth = entry.value
                        let previewNote = notesForMonth.first!

                        // Use the first payload for preview text (or URL)
                        let previewText: String = {
                            if let text = previewNote.payloads.first?.text {
                                return text
                            } else if let url = previewNote.payloads.first?.url {
                                return URL(string: url)?.lastPathComponent ?? url
                            } else {
                                return "No preview"
                            }
                        }()

                        NavigationLink(
                            destination: MonthlyView(month: monthString, notes: notesForMonth)
                        ) {
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.magnetPink.opacity(0.3))
                                    .frame(height: 120)
                                    .shadow(radius: 2)

                                VStack(alignment: .leading) {
                                    Text(monthString)
                                        .font(.headline)
                                        .foregroundColor(.black)

                                    Text(previewText)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .padding()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle(month)
        }
    }
}

// MARK: – Preview

struct MonthlyView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleNotes: [StickyNote] = [
            StickyNote(
                senderID: "user_001",
                familyID: "family_ABC",
                type: .text,
                timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 10))!,
                seen: [:],
                payloads: [Payload(text: "Anna's Birthday 🎂", url: nil)]
            ),
            StickyNote(
                senderID: "user_002",
                familyID: "family_ABC",
                type: .text,
                timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 20))!,
                seen: [:],
                payloads: [Payload(text: "Trip to Paris 🇫🇷", url: nil)]
            ),
            StickyNote(
                senderID: "user_003",
                familyID: "family_ABC",
                type: .text,
                timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 1))!,
                seen: [:],
                payloads: [Payload(text: "New School Year 📚", url: nil)]
            )
        ]

        return NavigationStack {
            MonthlyView(month: "May 2025", notes: sampleNotes)
        }
    }
}
