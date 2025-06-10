import SwiftUI
import FirebaseAuth

struct SideBarView: View {
    // MARK: – Colors
    private let magnetBrown  = Color(red: 75.0/255.0,  green: 54.0/255.0,  blue: 33.0/255.0) // #4B3621
    private let circleBG     = Color(red: 226.0/255.0, green: 220.0/255.0, blue: 211.0/255.0) // light beige

    // MARK: – Sample avatar for “Profile” row
    private let avatarImage = Image("avatarPlaceholder") // replace with your asset name

    var body: some View {
        // The outer HStack ensures the sidebar only occupies a fixed width on the leading edge,
        // leaving the rest of the screen transparent (or to be dimmed by a parent if needed).
        HStack(spacing: 0) {
            // ───────────────────── Sidebar Content ─────────────────────
            VStack(alignment: .leading, spacing: 32) {
                // HOME ROW
                //Navigate to home
                NavigationLink(destination: MainView()) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(circleBG)
                                .frame(width: 60, height: 60)
                            Image(systemName: "house.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(magnetBrown)
                        }

                        Text("Home")
                            .font(.title3)
                            .foregroundColor(.black)
                        
                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)

                    }
                }

                // ARCHIVE ROW
                NavigationLink(destination: CalendarView(notes: [
                    StickyNote(
                        senderID: "user1",
                        familyID: "fam1",
                        type: .text,
                        timeStamp: Date(),
                        seen: [:],
                        text: "Sample Note",
                        payloadURL:nil
                    )
                ]))  {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(circleBG)
                                .frame(width: 60, height: 60)
                            Image(systemName: "archivebox.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(magnetBrown)
                        }

                        Text("Archive")
                            .font(.title3)
                            .foregroundColor(.black)
                        
                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }

                // PROFILE ROW
                //Navigate to profile
                    NavigationLink(destination: ProfileView()) {
                    HStack(spacing: 16) {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .shadow(radius: 2)

                        Text("Profile")
                            .font(.title3)
                            .foregroundColor(.black)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }

                // LOGOUT ROW
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        NotificationCenter.default.post(name: Notification.Name("UserDidLogout"), object: nil)
                    } catch {
                        print("❌ Failed to logout: \(error.localizedDescription)")
                    }
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(circleBG)
                                .frame(width: 60, height: 60)
                            Image(systemName: "iphone.and.arrow.right.outward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(magnetBrown)
                                .fontWeight(.bold)
                        }

                        Text("Logout")
                            .font(.title3)
                            .foregroundColor(.black)

                        Spacer()
                    }
                }

                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .frame(width: 280)             // FIXED WIDTH of the sidebar
            .background(Color.white)       // Solid white background for sidebar
            .edgesIgnoringSafeArea(.all)   // Fill vertically under status bar

            // ───────────────────── Transparent Remainder ─────────────────────
            // This Spacer ensures the sidebar occupies only the left side.
            // The rest of the HStack fills the screen but is fully transparent.
            Spacer()
        }
        .edgesIgnoringSafeArea(.all) // Allow sidebar to extend under safe areas
    }
}

// MARK: – Preview
struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
            // Preview in a full‐screen container so we can see the transparent area:
            .previewLayout(.fixed(width: 768, height: 1024))
    }
}
