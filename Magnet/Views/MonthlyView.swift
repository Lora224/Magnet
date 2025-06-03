// MonthlyView.swift
import SwiftUI

struct MonthlyView: View {
    let month: String
    let notes: [ArchiveNote]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    private var groupedNotes: [String: [ArchiveNote]] {
           Dictionary(grouping: sampleNotes) { note in
               let formatter = DateFormatter()
               formatter.dateFormat = "LLLL yyyy"
               return formatter.string(from: note.date)
           }
       }
    @State private var selectedMonth: String? = nil


    var body: some View {
        VStack {
            HStack {
                
                
                // Wrap the text and rectangle together
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
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 60, height: 30)
                            .foregroundColor(Color.magnetBrown)
                            .padding(.leading, 30)

                        Spacer()

                    }
                )

                
                .frame(maxHeight: .infinity, alignment: .top) // this line helps when inside a parent with defined height

            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
    
        .ignoresSafeArea(.all, edges: .top)
        Text("Notes")
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groupedNotes.keys.sorted(), id: \.self) { month in
                    NavigationLink(destination: MonthlyView(month: month, notes: groupedNotes[month]!)) {
                        let notes = groupedNotes[month]!
                        let previewNote = notes.first ?? ArchiveNote(text: "No Notes", date: Date(), color: .gray)

                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(previewNote.color)
                                .frame(height: 120)
                                .shadow(radius: 2)

                            VStack(alignment: .leading) {
                                Text(month)
                                    .font(.headline)
                                Text(previewNote.text)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                            .padding()
                            .foregroundColor(.black)
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
    #Preview {
        MonthlyView(
            month: "January",
            notes: [
                ArchiveNote(text: "Buy groceries", date: Date(), color: .yellow),
                ArchiveNote(text: "Meeting notes", date: Date(), color: .pink),
                ArchiveNote(text: "Vacation plan", date: Date(), color: .blue)
            ])
        
    }


