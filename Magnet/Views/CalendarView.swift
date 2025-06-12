import SwiftUI
import SwiftData
import Foundation

struct CalendarView: View {
    let notes: [StickyNote]

        init(notes: [StickyNote] = generateDummyStickyNotes()) {
            self.notes = CalendarView.generateDummyStickyNotes()
        }
    @State private var selectedMonth: String = Calendar.current.monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
    
    @State private var isSidebarVisible = false

    private var columns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible())
    ]

    private var groupedNotes: [String: [StickyNote]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"

        let filteredNotes = notes.filter {
            let year = Calendar.current.component(.year, from: $0.timeStamp)
            return String(year) == selectedYear
        }

        return Dictionary(grouping: filteredNotes) {
            formatter.string(from: $0.timeStamp)
        }
    }


    private var sortedMonths: [String] {
        Calendar.current.monthSymbols
    }
    private var sortedYears: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let range = (2021...currentYear)
        return range.map { String($0) }
    }

    @State private var selectedYear: String = {
        let currentYear = Calendar.current.component(.year, from: Date())
        var years = ["2021", "2022", "2023", "2024", "2025"]
        return years.contains("\(currentYear)") ? "\(currentYear)" : years.last!
    }()

    var body: some View {
        VStack {
            // Header
            HStack {
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
                }
                .overlay(
                    HStack {
                        Button(action: {
                            withAnimation {
                                isSidebarVisible.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 60, height: 30)
                                .foregroundColor(Color.magnetBrown)
                                .padding(.leading, 30)
                        }
                        Spacer()
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .top)

            // Month selector and grid
            VStack {
                HStack{
                    Menu {
                        ForEach(sortedMonths, id: \.self) { month in
                            Button(action: {
                                selectedMonth = month
                            }) {
                                Text(month.capitalized)
                            }
                        }
                    } label: {
                        Label(selectedMonth, systemImage: "calendar")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color.magnetBrown)

                    }
                    Menu {
                        ForEach(sortedYears, id: \.self) { year in
                            Button(action: {
                                selectedYear = year
                            }) {
                                Text(year.capitalized)
                            }
                        }
                    } label: {
                        Label(selectedYear, systemImage: "calendar")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color.magnetBrown)
                    }
                }

                .padding(.top, 16)
                
                var notesForSelectedMonth: [StickyNote]? {
                    groupedNotes[selectedMonth]
                }

                if let notes = notesForSelectedMonth {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(notes, id: \.id) { note in
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
                } else {
                    Text("No notes for this month.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
//        .navigationTitle("Calendar")
    }

    func previewText(for note: StickyNote) -> String {
        note.text ?? "Media note"
    }

    func backgroundColor(for note: StickyNote) -> Color {
        switch note.type {
        case .text: return Color.magnetPink.opacity(0.3)
        case .image: return Color.magnetYellow.opacity(0.3)
        case .video: return Color.magnetBlue.opacity(0.3)
        case .audio: return Color.magnetBrown.opacity(0.2)
        case .drawing: return Color.magnetBrown.opacity(0.3)
        }
    }

    static func generateDummyStickyNotes() -> [StickyNote] {
        let sampleTextPayload = Payload(text: "Don't forget the milk!")
        let sampleImagePayload = Payload(url: "https://example.com/image1.jpg")
        let sampleVideoPayload = Payload(url: "https://example.com/video1.mov")
        let sampleAudioPayload = Payload(url: "https://example.com/audio1.m4a")

        return [
            StickyNote(
                senderID: "user001",
                familyID: "fam001",
                type: .text,
                timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 1))!,
                seen: ["user002": .smile, "user003": nil],
                text:"My first note",
                payloadURL:sampleTextPayload.url

            ),
            StickyNote(
                senderID: "user002",
                familyID: "fam001",
                type: .image,
                timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 2))!,
                seen: ["user001": .clap],
                text:"My first image note",
                payloadURL:sampleImagePayload.url
            ),
            StickyNote(
                senderID: "user003",
                familyID: "fam002",
                type: .video,
                timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 3))!,
                seen: ["user001": nil, "user002": .liked],
                text:"My first video note",
                payloadURL:sampleVideoPayload.url
            ),
            StickyNote(
                senderID: "user004",
                familyID: "fam001",
                type: .audio,
                timeStamp: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 4))!,
                seen: [:],
                text:"My first audio note",
                payloadURL:sampleAudioPayload.url
            )
        ]
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CalendarView()
        }
    }
}
