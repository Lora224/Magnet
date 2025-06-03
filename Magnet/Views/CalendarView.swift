//
//  TopFamilyBar.swift
//  Magnet
//
//  Created by Yutong Li on 2/6/2025.
//

//
//  CalendarView.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

//
import SwiftUI

struct CalendarView: View {
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetPink    = Color(red: 0.945, green: 0.827, blue: 0.808) // #F1D3CE
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855) // #FFF5DA
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6


    private var groupedNotes: [String: [ArchiveNote]] {
           Dictionary(grouping: sampleNotes) { note in
               let formatter = DateFormatter()
               formatter.dateFormat = "LLLL yyyy"
               return formatter.string(from: note.date)
           }
       }
    @State private var selectedMonth: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(magnetYellow)
                    .frame(height: 100)

                HStack(spacing: 10) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 50))

                    Text("🎉")
                        .font(.system(size: 50))
                        .padding(.leading, 35)

                    Text("Family 1")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(magnetBrown)
                        .textCase(.uppercase)
                        .padding(.trailing, 35)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 50))
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .overlay(
                HStack {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 80, height: 40)
                        .foregroundColor(magnetBrown)
                        .padding(.leading, 40)

                    Spacer()

                    Image(systemName: "ellipsis")
                        .opacity(0)
                        .padding(.trailing, 16)
                }
            )
            // Ensure it stretches horizontally
            .frame(maxWidth: .infinity)
            HStack{
                // Events text immediately below the yellow bar
//                Text("2025")
//                    .font(.system(size: 50, weight: .bold))
//                    .foregroundColor(magnetBrown)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.top, 16)
            
                Menu {
                    ForEach(groupedNotes.keys.sorted(), id: \.self) { month in
                        Button(action: {
                            selectedMonth = month
                        }) {
                            Text(month.capitalized)
                        }
                    }
                } label: {
                    Label("Select Year", systemImage: "calendar")
                        .font(.system(size: 50, weight: .bold))
                        
                }
                if let month = selectedMonth, let notes = groupedNotes[month] {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(notes) { note in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(note.color)
                                .frame(height: 120)
                                .overlay(
                                    Text(note.text)
                                        .padding()
                                        .font(.body)
                                        .foregroundColor(.black),
                                    alignment: .bottomLeading
                                )
                        }
                    }
                    .padding()
                    
                }
                Menu {
                    ForEach(groupedNotes.keys.sorted(), id: \.self) { month in
                        Button(action: {
                            selectedMonth = month
                        }) {
                            Text(month.capitalized)
                        }
                    }
                } label: {
                    Label("Select Month", systemImage: "calendar")
                        .font(.system(size: 50, weight: .bold))
                        
                }
                if let month = selectedMonth, let notes = groupedNotes[month] {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(notes) { note in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(note.color)
                                .frame(height: 120)
                                .overlay(
                                    Text(note.text)
                                        .padding()
                                        .font(.body)
                                        .foregroundColor(.black),
                                    alignment: .bottomLeading
                                )
                        }
                    }
                    .padding()
                    
                }


//                    
//                Text("Events")
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .font(.system(size: 50, weight: .bold))
//                    .foregroundColor(magnetBrown)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.top, 16)
                
            }
            
//            ScrollView {
//                LazyVStack(spacing: 16) {
//                    ForEach(groupedNotes.keys.sorted(), id: \.self) { month in
//                        NavigationLink(destination: MonthlyView(month: month, notes: groupedNotes[month]!)) {
//                            let notes = groupedNotes[month]!
//                            let previewNote = notes.first ?? ArchiveNote(text: "No Notes", date: Date(), color: .gray)
//
//                            ZStack(alignment: .bottomLeading) {
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(previewNote.color)
//                                    .frame(height: 120)
//                                    .shadow(radius: 2)
//
//                                VStack(alignment: .leading) {
//                                    Text(month)
//                                        .font(.headline)
//                                    Text(previewNote.text)
//                                        .font(.subheadline)
//                                        .lineLimit(1)
//                                }
//                                .padding()
//                                .foregroundColor(.black)
//                            }
//                            .padding(.horizontal)
//                        }
//
//                    }
//                }
//                .padding(.top)
//            }

                    .navigationTitle("Archive")
            

            Spacer()
        }
        .ignoresSafeArea(.all, edges: .top)
    }

}



#Preview(traits: .landscapeLeft) {
    CalendarView()
}
