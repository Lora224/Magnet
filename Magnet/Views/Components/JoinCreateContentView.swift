import SwiftUI

struct JoinCreateContentView: View {
    let geo: GeometryProxy
    @Binding var familyName: String
    @Binding var backgroundColor: Color
    @Binding var showLinkField: Bool
    @Binding var linkURL: String

    @ObservedObject var famManager: Sid
    @ObservedObject var authManager: AuthManager

    @State private var isJoining = false

    private let magnetBrown = Color(red: 0.294, green: 0.212, blue: 0.129)

    var body: some View {
        VStack {
            Spacer().frame(height: 60)

            Text("Let’s get started!")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(magnetBrown)
                .multilineTextAlignment(.center)
                .frame(maxWidth: geo.size.width * 0.5)
                .padding(.bottom, 5)

            Text("✈️🏞️🏅🐶📸 🍕🤳🚗📝👫☺️")
                .font(.system(size: 35, weight: .bold))
                .padding(.bottom, 20)
                .kerning(3)

            VStack(spacing: 15) {
                // Join button
                Button {
                    withAnimation {
                        showLinkField.toggle()
                        if !showLinkField {
                            linkURL = ""
                        }
                    }
                } label: {
                    Text("Join")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .kerning(2)
                        .frame(width: geo.size.width * 0.4, height: 80)
                        .background(magnetBrown)
                        .cornerRadius(16)
                }

                // Link field + Go button
                if showLinkField {
                    VStack(spacing: 10) {
                        TextField("", text: $linkURL)
                            .font(.system(size: 20))
                            .padding(12)
                            .frame(width: geo.size.width * 0.4)
                            .background(magnetBrown.opacity(0.1))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .overlay(
                                Group {
                                    if linkURL.isEmpty {
                                        Text("Enter link here")
                                            .font(.system(size: 20))
                                            .foregroundColor(magnetBrown)
                                            .padding(.leading, 16)
                                    }
                                },
                                alignment: .leading
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))

                        let code = famManager.extractInviteCode(from: linkURL)

                        Button(action: {
                            isJoining = true
                            famManager.joinFamily(with: code) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    authManager.isUserLoggedIn = true
                                    isJoining = false
                                }
                            }
                        }) {
                            Text(isJoining ? "Joining..." : "Go")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .kerning(2)
                                .frame(width: geo.size.width * 0.4, height: 80)
                                .background(isJoining ? Color.gray : magnetBrown)
                                .cornerRadius(16)
                        }
                        .disabled(isJoining || linkURL.isEmpty)
                    }
                }

                // Create Family button
                Button(action: {
                    famManager.regoFam(
                        familyName: "Family 1",
                        backgroundColor: Color.magnetYellow
                    )

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        authManager.isUserLoggedIn = true
                    }
                }) {
                    Text("Create Family")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .kerning(2)
                        .frame(width: geo.size.width * 0.4, height: 80)
                        .background(magnetBrown)
                        .cornerRadius(16)
                }
            }
            .padding(.bottom, 70)
        }
    }
}
