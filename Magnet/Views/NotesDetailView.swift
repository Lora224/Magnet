import SwiftUI
import FirebaseFirestore

struct NotesDetailView: View {
    let note: StickyNote
    private let lightGray = Color(red: 0.98, green: 0.98, blue: 0.98)
    private let profilePic = ["profile1", "profile2", "profile3"]
    
    @State private var isSeenPanelOpen = false
    
    var body: some View {
        ZStack {
            // Background content
            ZStack(alignment: .bottom) {
                VStack (spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 35)
                            .fill(lightGray)
                            .frame(width: 500, height: 80)
                        
                        HStack(spacing: 90) {
                            Image("heartMagnet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                            Image("clapMagnet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                            Image("laughMagnet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        }
                    }
                 
                    
                    // Chevron to reveal panel
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 60))
                        .foregroundColor(Color.magnetBrown)
                        .onTapGesture {
                            withAnimation {
                                isSeenPanelOpen = true
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 30)
                                .onEnded { value in
                                    if value.translation.height < -10 {
                                        withAnimation {
                                            isSeenPanelOpen = true
                                        }
                                    }
                                }
                        )
                }
                TopFamilyBar()
                Spacer()
                
                // Magnet Reactions Bar
                
            }
            .zIndex(3)
            .background {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(0..<3) { index in
                                ZStack(alignment: .top) {
                                    Image("blueNotePlain")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 700)
                                        .clipped()
                                        .shadow(color: Color.black.opacity(0.10), radius: 15, x: 10, y: 10)
                                    
                                    SenderProfileView(userID: note.senderID)
                                      .frame(width: 120, height: 120)
                                      .offset(y: 40)

                                }
                            }
                        }
                    }
                }
                .padding(.top, 120)
            }
            
            // Back Arrow
            VStack {
                HStack {
                    Image(systemName: "arrowshape.backward.fill")
                        .font(.system(size: 50))
                        .padding(.leading, 30)
                        .padding(.top, 100)
                    Spacer()
                }
                Spacer()
            }

            // Seen-by Slide-up Panel
            if isSeenPanelOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isSeenPanelOpen = false
                        }
                    }
                    .zIndex(10)

                VStack(spacing: 20) {
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 60, height: 6)
                        .padding(.top, 10)

                    VStack(spacing: 20) {
                        seenRow(name: "Margaret", image: "profile1")
                        Divider()
                        seenRow(name: "John", image: "profile2")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 300)
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom))
                .zIndex(11)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea(.all, edges: .top)
    }
    
    @ViewBuilder
    func seenRow(name: String, image: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Image(image)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .offset(x: 10, y: 10)
            }
            Text(name)
                .font(.title3.bold())
            Spacer()
        }
    }
}

#Preview {
    NotesDetailView(note: StickyNote(
        id: UUID(),
        senderID: "user1",
        familyID: "fam",
        type: .text,
        timeStamp: Date(),
        seen: ["user1": .clap, "user2": .liked],
        text: "Grandma’s apple pie was amazing!",
        payloadURL: nil
    ))
}
