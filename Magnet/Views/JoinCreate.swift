import SwiftUI

struct JoinCreate: View {
    @State private var familyName = ""
    @State private var backgroundColor = Color(red: 0.82, green: 0.914, blue: 0.965)
    @State private var showLinkField = false
    @State private var linkURL = ""

    @StateObject private var famManager = Sid()

    private let magnetBrown = Color(red: 0.294, green: 0.212, blue: 0.129)

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    ZStack {
                        GridPatternBackground()
                            .ignoresSafeArea()

                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.88))
                            .frame(
                                width: geo.size.width * 0.7,
                                height: geo.size.height * 0.6
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 15)
                            .overlay(
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
                                                .frame(
                                                    width: geo.size.width * 0.4,
                                                    height: 80
                                                )
                                                .background(magnetBrown)
                                                .cornerRadius(16)
                                        }

                                        if showLinkField {
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
                                        }

                                        // Create button → trigger famManager.regoFam
                                        Button(action: {
                                            famManager.regoFam(
                                                familyName: "Family 1",
                                                backgroundColor: Color.magnetYellow,
                                                                                    )
                                                                                })  {
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
                            )
                            .position(
                                x: geo.size.width / 2,
                                y: geo.size.height / 2
                            )
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationDestination(isPresented: $famManager.navigateToHome) {
                if let family = famManager.family {
                                    FamilyGroupView(
                                        familyName: family.name, familyEmoji: "",
                                        backgroundColor: Color(
                                            red: family.red,
                                            green: family.green,
                                            blue: family.blue
                                        )
                                    )
                                } else {
                                    Text("Family not found.")
                                }
            }
        }
    }
}

#Preview {
    JoinCreate()
}

