import SwiftUI

struct JoinCreate: View {
    // Dark brown for text/buttons
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Full-screen grid background
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
                
                // Centered, semi-opaque rounded “card”
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.88))
                    .frame(
                        width: geo.size.width * 0.7,
                        height: geo.size.height * 0.6
                    )
                    .shadow(
                        color: Color.black.opacity(0.2), // 50% opacity black
                        radius: 15                  // drop it down by 5 points
                    )
                    .overlay(
                        VStack {
                            // Push the title down a bit
                            Spacer()
                                .frame(height: 60)

                            Text("Let’s get started!")
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(magnetBrown)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: geo.size.width * 0.5)
                                .padding(.bottom, 10)
                            
                            Text("✈️🏞️🏅🐶📸 🍕🤳🚗📝👫☺️")
                                .font(.system(size: 30, weight: .bold))
                                .padding(.bottom, 30)

                               

                            // Two vertically stacked buttons, each 40% width and 100pt high
                            VStack(spacing: 15) {
                                Button(action: {
                                    // handle “Join” tap here
                                }) {
                                    Text("Join")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(
                                            width: geo.size.width * 0.4,
                                            height: 90
                                        )
                                        .background(magnetBrown)
                                        .cornerRadius(16)
                                }

                                Button(action: {
                                    // handle “Create” tap here
                                }) {
                                    Text("Create")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(
                                            width: geo.size.width * 0.4,
                                            height: 90
                                        )
                                        .background(magnetBrown)
                                        .cornerRadius(16)
                                }
                            }
                            .padding(.bottom, 70)
                        }
                    )
                    // Center the card in the middle of the screen
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height / 2
                    )
                
                Rectangle()
                    .fill(magnetBlue)
                    .frame(width: 290, height: 60)
                    .rotationEffect(.degrees(-40))
                    .position(
                        x: geo.size.width * 0.22,
                        y: geo.size.height * 0.25
                    )

                
            }
        }
    }
}

struct JoinCreate_Previews: PreviewProvider {
    static var previews: some View {
        JoinCreate()
    }
}
