import SwiftUI

struct FamilyGroupView: View {
    @StateObject private var famManager = Sid()
    @State private var showInviteSheet = false
    @State private var copySuccessMessage = ""
    @State private var selectedColor: Color = .white

    private let magnetBrown  = Color(red: 0.294, green: 0.212, blue: 0.129)
    private let magnetYellow = Color(red: 1.000, green: 0.961, blue: 0.855)

    private let pastelColors: [Color] = [
        Color(red: 1.0, green: 0.9, blue: 0.9),
        Color(red: 0.9, green: 1.0, blue: 0.9),
        Color(red: 0.9, green: 0.9, blue: 1.0),
        Color(red: 1.0, green: 1.0, blue: 0.9),
        Color(red: 0.9, green: 1.0, blue: 1.0),
        Color(red: 1.0, green: 0.9, blue: 1.0),
        Color(red: 0.95, green: 0.95, blue: 0.95),
        Color(red: 0.95, green: 0.85, blue: 0.7),
        Color(red: 0.8, green: 0.95, blue: 0.85),
        Color(red: 0.85, green: 0.8, blue: 0.95)
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
        NavigationStack {
            Group {
                if let family = famManager.family {
                    familyContent(for: family)
                        .sheet(isPresented: $showInviteSheet) {
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
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(familyColor, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbar(.hidden, for: .navigationBar) // if you're fully hiding it
                        .onAppear {
                            let actualColor = Color(red: family.red, green: family.green, blue: family.blue)
                            selectedColor = closestPastel(to: actualColor)
                        }
                        .onChange(of: famManager.family?.id) { _ in
                            if let newFamily = famManager.family {
                                let actualColor = Color(red: newFamily.red, green: newFamily.green, blue: newFamily.blue)
                                selectedColor = closestPastel(to: actualColor)
                            }
                        }
                }
            }
        }
        .onAppear {
            famManager.loadCurrentUserFamily()
        }
    }
    
    private func closestPastel(to color: Color) -> Color {
        func components(of color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
            let uiColor = UIColor(color)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
            return (r, g, b)
        }

        let target = components(of: color)

        return pastelColors.min(by: { a, b in
            let ca = components(of: a)
            let cb = components(of: b)

            let da = pow(ca.r - target.r, 2) + pow(ca.g - target.g, 2) + pow(ca.b - target.b, 2)
            let db = pow(cb.r - target.r, 2) + pow(cb.g - target.g, 2) + pow(cb.b - target.b, 2)

            return da < db
        }) ?? color
    }

    @ViewBuilder
    private func familyContent(for family: Family) -> some View {
        ZStack {
            familyColor.ignoresSafeArea()

            VStack(spacing: 24) {
                // Top bar
                HStack {
                    NavigationLink(destination: SideBarView()) {
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
                    ForEach(pastelColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(selectedColor == color ? 0.8 : 0), lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedColor = color
                                // snap to exact pastel before saving
                                famManager.updateFamilyColor(to: color)
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

                // Buttons
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
}

#Preview {
    FamilyGroupView()
}
