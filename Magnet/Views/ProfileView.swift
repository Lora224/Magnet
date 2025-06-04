import SwiftUI
struct FamilyCard: View {
    let family: Family
    let textColor: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color(
                    red: family.red,
                    green: family.green,
                    blue: family.blue))
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 4)

            Text("icon + \(family.name)")
                .font(.headline)
                .foregroundColor(textColor)
                .padding(8)
        }
    }
}

struct ProfileView: View {
    // Placeholder data for UI layout only
    private let avatarImage = Image("avatarPlaceholder") // Replace with Avatar pic
    private let userName = "Margaret"
    
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetPink    = Color(red: 0.945, green: 0.827, blue: 0.808) // #F1D3CE
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855) // #FFF5DA
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6

    
    private let families: [Family] = [
        Family(
            inviteURL: "https://magnet.app/invite/family1",
            memberIDs: ["user1", "user2"],
            red: 1.0,
            green: 0.961,
            blue: 0.855,
            profilePic: UIImage(named: "laughMagnet")?.pngData(),
        ),
        Family(
            inviteURL: "https://magnet.app/invite/family2",
            memberIDs: ["user3", "user4"],
            red: 0.945,
            green: 0.827,
            blue: 0.808,
            profilePic: UIImage(named: "laughMagnet")?.pngData(),
        ),
        Family(
            inviteURL: "https://magnet.app/invite/family3",
            memberIDs: ["user5"],
            red: 0.820,
            green: 0.914,
            blue: 0.965,
            profilePic: UIImage(named: "laughMagnet")?.pngData(),
        )
    ]

    
    // 2 equal‐width columns
        private let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation bar
            HStack {
                // Hamburger menu icon
                NavigationLink(destination: SideBarView()) {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .frame(width: 80,height: 40)
                        .foregroundColor(magnetBrown)
                        .padding(16)
                }
                
                Spacer()
                
                // Home icon
                NavigationLink(destination: MainView()) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 50,height: 50)
                        .font(.title2)
                        .foregroundColor(magnetBrown)
                        .padding(16)
                }
            }
            .padding(.top, 20)
           
            // Avatar with edit pencil overlay
            ZStack(alignment: .bottomTrailing) {
                avatarImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 168, height: 168)
                    .clipShape(Circle())
                    .shadow(radius: 6)
                
                // Edit button (static overlay)
                Button(action:{/*edit button action*/}){
                    Circle()
                        .fill(magnetBrown)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold))
                        )
                        .offset(x: 8, y: 8)
                }
            }
            .padding(.top, 8)
            
            // User name
            Text(userName)
                .font(.title)
                .bold()
                .padding(.top, 8)
            
            // 5-column grid of square “notes”
            ScrollView {
                LazyVGrid(columns: columns, spacing: 32) {
                    ForEach(families, id: \.id) { fam in
                        NavigationLink(
                            destination: FamilyGroupView(
                                familyName: fam.inviteURL,
                                familyEmoji: "👨‍👩‍👧‍👦",
                                backgroundColor: Color(red: fam.red, green: fam.green, blue: fam.blue)
                            )
                        ) {
                            FamilyCard(family: fam, textColor: magnetBrown)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: 240)
                        }
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: 240)

                        Image(systemName: "plus")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(magnetBrown)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }

            Spacer(minLength: 20)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: – Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
    }
}
