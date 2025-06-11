import SwiftUI

struct FamilyGroupView: View {
    @StateObject private var famManager = Sid()
    @State private var showInviteSheet = false
    @State private var copySuccessMessage = ""

    private let magnetBrown  = Color(red: 0.294, green: 0.212, blue: 0.129)
    private let magnetYellow = Color(red: 1.000, green: 0.961, blue: 0.855)

    var body: some View {
        NavigationStack {
            Group {
                if let family = famManager.family {
                    ZStack {
                        Color(red: family.red, green: family.green, blue: family.blue)
                            .ignoresSafeArea()

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
                            .background(Color(red: family.red, green: family.green, blue: family.blue))

                            // Emoji avatar
                            Text(family.emoji)
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

                            // Members list
                            ScrollView {
                                VStack(spacing: 12) {
                                    if famManager.userNames.isEmpty {
                                        Text("No members found.")
                                            .foregroundColor(.gray)
                                            .padding()
                                    } else {
                                        ForEach(famManager.userNames, id: \.self) { name in
                                            HStack {
                                                Image(systemName: "person.fill")
                                                    .frame(width: 40, height: 40)
                                                Text(name)
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
                }
            }
            .onAppear {
                famManager.loadCurrentUserFamily()
            }
        }
    }
}

#Preview {
    FamilyGroupView()
}
