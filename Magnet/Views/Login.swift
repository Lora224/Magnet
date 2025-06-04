import SwiftUI

struct Login: View {
    var body: some View {
        ZStack {
            // Background image
            Image("loginBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Gradient blur overlay
            LinearGradient(
                gradient: Gradient(stops: [
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .background(.ultraThinMaterial)
            .ignoresSafeArea()

            // Centered login card
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Text("Welcome to Magnet!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("A shared fridge to show your loved ones you care")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 110 / 255, green: 110 / 255, blue: 110 / 255))
                }

                Button(action: {
                    // Handle Apple Sign-In
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Continue with Apple")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .frame(width: 300)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }
}

#Preview {
    Login()
}
