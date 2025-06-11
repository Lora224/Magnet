import SwiftUI
import FirebaseAuth
struct SideBarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: – Colors
    private let magnetBrown  = Color(red: 75.0/255.0,  green: 54.0/255.0,  blue: 33.0/255.0)
    private let circleBG     = Color(red: 226.0/255.0, green: 220.0/255.0, blue: 211.0/255.0)

    private let avatarImage = Image("avatarPlaceholder")

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 32) {
                
                // HOME ROW
                Button(action: {
                    dismiss()
                }) {
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
                        payloadURL: nil
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
                if authManager.isUserLoggedIn {
                    Button(action: {
                        authManager.logout()
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
                } else {
                    Text("Logged out")
                        .foregroundColor(.gray)
                        .padding(.leading, 16)
                }

                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .frame(width: 280)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)

            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
