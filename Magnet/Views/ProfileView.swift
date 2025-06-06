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

struct ProfileAvatarView: View {
    let avatarImage: Image
    let editAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.white)
                .frame(width: 150, height: 150)
                .overlay(
                    avatarImage
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(4)
                )
                .shadow(radius: 6)

            Button(action: editAction) {
                Circle()
                    .fill(Color.magnetBrown)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    )
                    .offset(x: 8, y: 8)
            }
        }
    }
}

struct ProfileView: View {
    @State private var isSidebarVisible: Bool = false
    // Placeholder data for UI layout only
    private let avatarImage = Image("avatarPlaceholder") // Replace with Avatar pic
    private let userName = "Margaret"
    
    private let families: [Family] = [
        Family(
            inviteURL: "https://magnet.app/invite/family1",
            memberIDs: ["user1", "user2"],
            red: 1.0,
            green: 0.961,
            blue: 0.855,
            profilePic: UIImage(named: "laughMagnet")?.pngData()
        ),
        Family(
            inviteURL: "https://magnet.app/invite/family2",
            memberIDs: ["user3", "user4"],
            red: 0.945,
            green: 0.827,
            blue: 0.808,
            profilePic: UIImage(named: "laughMagnet")?.pngData()
        ),
        Family(
            inviteURL: "https://magnet.app/invite/family3",
            memberIDs: ["user5"],
            red: 0.820,
            green: 0.914,
            blue: 0.965,
            profilePic: UIImage(named: "laughMagnet")?.pngData()
        )
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                VStack(spacing: 0) {
                    // Top navigation bar
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSidebarVisible.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .frame(width: 60, height: 30)
                                .foregroundColor(.magnetBrown)
                                .padding(16)
                        }

                        Spacer()

                        NavigationLink(destination: MainView()) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .font(.title2)
                                .foregroundColor(.magnetBrown)
                                .padding(16)
                        }
                    }
                    .padding(.top, 20)

                    // Avatar + pencil overlay
                    ProfileAvatarView(avatarImage: avatarImage) {
                        // edit avatar button action
                        print("Edit avatar tapped")
                    }
                    .padding(.top, 8)

                    // User name
                    Text(userName)
                        .font(.title)
                        .bold()
                        .padding(.top, 8)

                    // Family grid
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
                                    FamilyCard(family: fam, textColor: .magnetBrown)
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(maxWidth: 240)
                                }
                            }

                            // Add family button
                            ZStack {
                                RoundedRectangle(cornerRadius: 0, style: .continuous)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(maxWidth: 240)

                                Image(systemName: "plus")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundColor(.magnetBrown)
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
                .disabled(isSidebarVisible)
                .blur(radius: isSidebarVisible ? 2 : 0)

                if isSidebarVisible {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isSidebarVisible = false
                            }
                        }
                }

                if isSidebarVisible {
                    SideBarView()
                        .frame(width: 280)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

