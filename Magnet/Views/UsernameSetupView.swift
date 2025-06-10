import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UsernameSetupView: View {
    @State private var username = ""
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    let onComplete: () -> Void

    private let magnetBrown = Color(red: 0.294, green: 0.212, blue: 0.129)

    var body: some View {
        ZStack {
            Color.black.opacity(0)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                Text("Please enter your username.\nYou can change it later.")
                    .font(.system(size: 25, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(magnetBrown)
                    .padding()

                HStack {
                    TextField("Username", text: $username)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)

                    Button(action: {
                        saveUsername()
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(width: 24, height: 24)
                        } else {
                            Text("Confirm")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(username.isEmpty || isLoading ? Color.gray : magnetBrown)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(username.isEmpty || isLoading)
                }
                .frame(maxWidth: 400)
            }
            .padding(60)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(maxWidth: 500)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveUsername() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showError(message: "Unable to get current user ID.")
            return
        }

        isLoading = true

        Firestore.firestore().collection("users").document(userID).setData([
            "name": username
        ], merge: true) { error in
            isLoading = false

            if let error = error {
                showError(message: "Failed to save username: \(error.localizedDescription)")
            } else {
                print("✅ Username saved successfully.")
                onComplete() // 👈 Call completion closure
            }
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

