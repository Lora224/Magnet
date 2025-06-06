import SwiftUI

struct JoinCreate: View {
    // Dark brown for text/buttons
    private let magnetBrown = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetBlue  = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6

    // State to toggle the inline link entry
    @State private var showLinkField = false
    // Holds whatever URL/text the user types
    @State private var linkURL = ""

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    ZStack {
                        // Full‐screen grid background
                        GridPatternBackground()
                            .ignoresSafeArea()

                        Image("heartMagnet")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.4)
                            .frame(width: geo.size.width * 0.73)
                            .rotationEffect(.degrees(15))
                            .position(
                                x: geo.size.width * 0.85,
                                y: geo.size.height * 0.20
                            )

                        Image("laughMagnet")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.4)
                            .frame(width: geo.size.width * 0.85)
                            .rotationEffect(.degrees(-20))
                            .position(
                                x: geo.size.width * 0.65,
                                y: geo.size.height * 0.88
                            )

                        Image("clapMagnet")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.4)
                            .frame(width: geo.size.width * 0.86)
                            .rotationEffect(.degrees(10))
                            .position(
                                x: geo.size.width * 0.20,
                                y: geo.size.height * 0.40
                            )

                        // Centered, semi‐opaque rounded “card”
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

                                    // VStack for buttons and conditional link entry
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

                                        // Inline TextField appears only when showLinkField == true
                                        if showLinkField {
                                            TextField("", text: $linkURL) {
                                                // no prompt string here
                                            }
                                            .font(.system(size: 20))
                                            .padding(12)
                                            .frame(width: geo.size.width * 0.4)
                                            .background(magnetBrown.opacity(0.1))
                                            .cornerRadius(10)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .overlay(
                                                // Custom placeholder in magnetBrown
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
                                            .transition(
                                                .move(edge: .top)
                                                    .combined(with: .opacity)
                                            )
                                        }

                                        // Create button → navigation to MainView
                                        NavigationLink {
                                            MainView()
                                                .navigationBarBackButtonHidden(true)

                                        } label: {
                                            Text("Create")
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
                                    }
                                    .padding(.bottom, 70)
                                }
                            )
                            .position(
                                x: geo.size.width / 2,
                                y: geo.size.height / 2
                            )

                        Rectangle()
                            .fill(magnetBlue)
                            .frame(
                                width: geo.size.width * 0.3,
                                height: geo.size.height * 0.08
                            )
                            .rotationEffect(.degrees(-40))
                            .position(
                                x: geo.size.width * 0.22,
                                y: geo.size.height * 0.25
                            )
                    }
                }
            }
            .ignoresSafeArea(.keyboard) // prevent squishing when keyboard appears
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    JoinCreate()
}
