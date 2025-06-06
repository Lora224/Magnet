import SwiftUI
import Firebase
import FirebaseAuth

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                
                Group {
                    TextField("email", text: $email)
                        .frame(width: 400, height: 8)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)

                    SecureField("password", text: $password)
                        .frame(width: 400, height: 8)
                        .submitLabel(.next)
                }
                .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Sign Up") {
                        
                    }
                    Spacer()
                    Button("Log In") {
                        
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 400)

//                Button(action: {
//                    // Handle Apple Sign-In
//                }) {
//                    HStack {
//                        Image(systemName: "apple.logo")
//                        Text("Continue with Apple")
//                            .fontWeight(.semibold)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.black)
//                    .foregroundColor(.white)
//                    .cornerRadius(15)
//                }
//                .frame(width: 300)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    func register () {
        Auth.auth().createUser(withEmail: email, password: password) { result,
            error in
            if let error = error {
                print("😡 LOGIN ERROR:\(error.localizedDescription)")
                alertMessage = "LOGIN ERROR: \(error.localizedDescription)"
                showingAlert = true
                
            } else {
                print("SUCCESS")
            }
        }
    }
}

#Preview {
    Login()
}
