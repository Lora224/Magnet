import SwiftUI

struct FamilyGroupView: View {
    @StateObject private var famManager = Sid()
    @State private var showInviteSheet = false
    @State private var copySuccessMessage = ""
    @State private var selectedPastelColor: PastelColor?
    @State private var isSidebarVisible = false   // ⭐️ 和 ProfileView 一样！

    let familyID: String

    private let magnetBrown  = Color(red: 0.294, green: 0.212, blue: 0.129)

    struct PastelColor: Hashable {
        let color: Color
        let red: Double
        let green: Double
        let blue: Double
    }

    private let pastelColors: [PastelColor] = [
        PastelColor(color: Color(red: 1.0, green: 0.9, blue: 0.9), red: 1.0, green: 0.9, blue: 0.9),
        PastelColor(color: Color(red: 0.9, green: 1.0, blue: 0.9), red: 0.9, green: 1.0, blue: 0.9),
        PastelColor(color: Color(red: 0.9, green: 0.9, blue: 1.0), red: 0.9, green: 0.9, blue: 1.0),
        PastelColor(color: Color(red: 1.0, green: 1.0, blue: 0.9), red: 1.0, green: 1.0, blue: 0.9),
        PastelColor(color: Color(red: 0.9, green: 1.0, blue: 1.0), red: 0.9, green: 1.0, blue: 1.0),
        PastelColor(color: Color(red: 1.0, green: 0.9, blue: 1.0), red: 1.0, green: 0.9, blue: 1.0),
        PastelColor(color: Color(red: 0.95, green: 0.95, blue: 0.95), red: 0.95, green: 0.95, blue: 0.95),
        PastelColor(color: Color(red: 0.95, green: 0.85, blue: 0.7), red: 0.95, green: 0.85, blue: 0.7),
        PastelColor(color: Color(red: 0.8, green: 0.95, blue: 0.85), red: 0.8, green: 0.95, blue: 0.85),
        PastelColor(color: Color(red: 0.85, green: 0.8, blue: 0.95), red: 0.85, green: 0.8, blue: 0.95)
    ]

    private var familyColor: Color {
        if let family = famManager.family {
            return Color(red: family.red, green: family.green, blue: family.blue)
        }
        return .white
    }

    private var familyEmoji: String {
        famManager.family?.emoji ?? "👪"
    }

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationStack {
                Group {
                    if let family = famManager.family {
                        familyContent(for: family)
                            .sheet(isPresented: $showInviteSheet) {
                                inviteSheetContent()
                            }
                            .toolbarBackground(familyColor, for: .navigationBar)
                            .toolbar(.hidden, for: .navigationBar)
                            .onAppear {
                                syncSelectedColor(with: family)
                            }
                            .onChange(of: famManager.family?.id) { _ in
                                if let newFamily = famManager.family {
                                    syncSelectedColor(with: newFamily)
                                }
                            }
                    }
                }
                .onAppear {
                    famManager.loadFamily(familyID)
                }
            }

            // ⭐️ Sidebar 部分 → 和 ProfileView 一致
            if isSidebarVisible {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isSidebarVisible = false }
                    }
                    .zIndex(1)

                SideBarView()
                    .frame(width: 280)
                    .transition(.move(edge: .leading))
                    .zIndex(2)
            }
        }
    }

    private func syncSelectedColor(with family: Family) {
        let actualColor = Color(red: family.red, green: family.green, blue: family.blue)
        selectedPastelColor = closestPastel(to: actualColor)
    }

    private func closestPastel(to color: Color) -> PastelColor {
        func components(of color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
            let uiColor = UIColor(color)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
            return (r, g, b)
        }

        let target = components(of: color)

        return pastelColors.min(by: { a, b in
            let ca = (CGFloat(a.red), CGFloat(a.green), CGFloat(a.blue))
            let cb = (CGFloat(b.red), CGFloat(b.green), CGFloat(b.blue))

            let da = pow(ca.0 - target.r, 2) + pow(ca.1 - target.g, 2) + pow(ca.2 - target.b, 2)
            let db = pow(cb.0 - target.r, 2) + pow(cb.1 - target.g, 2) + pow(cb.2 - target.b, 2)

            return da < db
        }) ?? pastelColors.first!
    }

    @ViewBuilder
    private func familyContent(for family: Family) -> some View {
        ZStack {
            familyColor.ignoresSafeArea()

            VStack(spacing: 24) {
                // Top bar
                HStack {
                    Button {
                        withAnimation(.easeInOut) { isSidebarVisible.toggle() }  // ⭐️ 和 ProfileView 一样
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .frame(width: 65, height: 35)
                            .foregroundColor(magnetBrown)
                            .padding(.leading, 25)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .background(familyColor)

                // Emoji avatar
                Text(familyEmoji)
                    .font(.system(size: 75))

                // Editable family name
                TextField("Family name", text: Binding(
                    get: { famManager.family?.name ?? "" },
                    set: { famManager.family?.name = $0 }
                ))
                .font(.title).bold()
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                )
                .frame(width: 240)
                .onSubmit {
                    if let newName = famManager.family?.name {
                        famManager.updateFamilyName(newName: newName)
                    }
                }

                Text("Choose a color:")
                    .font(.subheadline)
                    .padding(.top, 10)

                HStack(spacing: 10) {
                    ForEach(pastelColors, id: \.self) { pastel in
                        Circle()
                            .fill(pastel.color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(selectedPastelColor == pastel ? 0.8 : 0), lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedPastelColor = pastel
                                famManager.updateFamilyColor(r: pastel.red, g: pastel.green, b: pastel.blue)
                            }
                    }
                }
                .padding(.bottom, 10)

                // Members list
                ScrollView {
                    VStack(spacing: 12) {
                        if famManager.userSummaries.isEmpty {
                            Text("No members found.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(famManager.userSummaries) { user in
                                HStack(spacing: 12) {
                                    if let urlString = user.profilePictureURL, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 40, height: 40)
                                        }
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    }

                                    Text(user.name)
                                        .font(.headline)

                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer()

                // Bottom buttons
                HStack(spacing: 20) {
                    Button {
                        if let updatedName = famManager.family?.name {
                            famManager.updateFamilyName(newName: updatedName)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.circle")
                                .font(.system(size: 30))
                            Text("Update")
                                .font(.title3).bold()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 32)
                        .background(magnetBrown)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }

                    Button(action: {
                        showInviteSheet = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "link")
                                .font(.system(size: 30, weight: .regular))
                                .frame(width: 50, height: 35)
                            Text("Invite")
                                .font(.title3).bold()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 32)
                        .background(magnetBrown)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal)
        }
    }

    private func inviteSheetContent() -> some View {
        VStack(spacing: 24) {
            Text("Invite Link")
                .font(.title2).bold()
                .padding(.top)

            if let inviteCode = famManager.family?.inviteURL {
                let inviteLink = "https://magnetapp.com/invite/\(inviteCode)"

                Text(inviteLink)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .contextMenu {
                        Button("Copy", action: {
                            UIPasteboard.general.string = inviteLink
                            copySuccessMessage = "Copied!"
                        })
                    }

                Button(action: {
                    UIPasteboard.general.string = inviteLink
                    copySuccessMessage = "Copied!"
                }) {
                    Text("Copy Link")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(magnetBrown)
                        .cornerRadius(12)
                }

                if !copySuccessMessage.isEmpty {
                    Text(copySuccessMessage)
                        .foregroundColor(.green)
                }
            } else {
                Text("Invite link not available.")
            }

            Spacer()
        }
        .padding()
    }
}

